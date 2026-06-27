# Runbook: `backfill_seller_valid_from`

## What this macro does

Corrects `dbt_valid_from` on `sellers_snapshot` for sellers' first (earliest) record, replacing the timestamp of when the snapshot was first run with each seller's actual first order date — derived from `stg_ecom__order_items` joined to `stg_ecom__orders`.

## When this needs to be run

This is a **one-time, manual operation** — not part of the regular `dbt run` / `dbt build` cycle. It needs to be run (or re-run from scratch) only when:

- `sellers_snapshot` is being stood up for the first time against a **historic full dump** of seller data — i.e. a dataset where each seller appears as a single row with no genuine "joined platform" or "record created" timestamp in the source.
- In this situation, dbt snapshots set `dbt_valid_from` to whenever the snapshot *first ran*, not any real historical date — because a snapshot is an ongoing change-detection mechanism, not a backfill tool. There is no reliable source column for "when did this seller actually start" — the only available proxy is **each seller's first order date**, since that's the earliest point at which the seller's attributes are known to have existed and mattered to the business.
- If `sellers_snapshot` is ever rebuilt from scratch (e.g. full historical reload, or a fresh environment build), this macro needs to be re-run afterward, for the same reason it was needed the first time.

This macro does **not** need to be run after normal, ongoing snapshot runs — once `dbt_valid_from` is correctly backfilled, future snapshot runs only add new rows when a seller's tracked attributes (`seller_zip_code_prefix`, `seller_city`, `seller_state`) actually change, and those new rows get a correct, real `dbt_valid_from` automatically.

---

## Pre-flight checks

**1. Sanity-check the backfill logic in isolation, before touching any real data.**

Run just the inner subquery as a standalone `SELECT` — not the full macro — to confirm the dates it produces look correct:

```sql
select 
    oi.seller_id,
    min(o.order_purchase_timestamp) as first_order_date
from analytics.ecom.stg_ecom__order_items oi
inner join analytics.ecom.stg_ecom__orders o
    on oi.order_id = o.order_id
group by oi.seller_id
limit 10;
```

Confirm: dates fall within the expected historical range (e.g. 2017–2018 for Olist), no unexpected NULLs, no obviously wrong values.

**2. Capture a small, targeted snapshot of current state — not a full table backup.**

Pick a handful of known `seller_id` values and record their current `dbt_valid_from` / `dbt_valid_to` before making any changes:

```sql
select seller_id, dbt_valid_from, dbt_valid_to 
from analytics.snapshot.sellers_snapshot 
where seller_id in ('<seller_id_1>', '<seller_id_2>', '<seller_id_3>');
```

A full backup of `sellers_snapshot` is deliberately **not** required here — at production scale, copying the entire table would consume meaningful storage and compute for a check whose only purpose is a before/after comparison on a handful of rows. This is a proportional safety check, not disaster recovery.

---

## Execution

```bash
dbt run-operation backfill_seller_valid_from
```

Expect to see `Backfill complete` logged on success. This confirms the macro's SQL was compiled **and executed** (via `run_query()`) — not just compiled and discarded, which was an earlier bug encountered while building this macro.

---

## Post-run verification

**1. Re-run the same targeted query from Pre-flight Check 2**, on the same `seller_id` values, and confirm `dbt_valid_from` has changed to the expected earlier date (matching what the isolated subquery showed in Pre-flight Check 1). `dbt_valid_to` should be unchanged.

**2. Rebuild `dim_sellers` and `fct_order_items`.** `dim_sellers` is a plain model that reads from `sellers_snapshot` — it will not reflect the corrected `dbt_valid_from` values until it's rebuilt. `fct_order_items` then needs to re-run its temporal join against the corrected `dim_sellers`:

```bash
dbt run --select dim_sellers fct_order_items --full-refresh
```

A `--full-refresh` is used here rather than a normal incremental run, since the join condition itself has changed retroactively for historical rows already in the table — an incremental run would only reprocess recent rows under the lookback window, leaving older historical rows still pointing at the pre-backfill (incorrect) seller attributes.

**3. Validate downstream impact.** Query `fct_order_items` for historical orders and confirm seller attributes (`seller_state`, `seller_city`, `seller_zip_code_prefix`) are now populated instead of `NULL`:

```sql
select order_id, seller_id, seller_state, seller_city
from analytics.ecom.fct_order_items
limit 20;
```

If seller attributes are still `NULL` for historical orders after this, double-check that `dim_sellers` actually picked up the corrected `dbt_valid_from` values from step 1 before assuming the temporal join itself is broken.

---

## Known limitations

- **Sellers with zero orders are not touched by this backfill.** The macro's subquery uses an `INNER JOIN` between `order_items` and `orders`, which naturally excludes any seller who never appears in an order. This is intentional, not an oversight: a seller with zero orders will never be matched by any temporal join in `fct_order_items` anyway, so their `dbt_valid_from` being "wrong" relative to some imagined real-world date has no real-world consequence to chase. Adding a synthetic default date for them would add complexity to solve a non-existent problem.

- **`dbt_scd_id` becomes cosmetically stale** after this manual edit, since it's partially derived from the same timestamp this macro overwrites. This is harmless: nothing in `dim_sellers` or `fct_order_items` references `dbt_scd_id` directly, and future change-detection on `sellers_snapshot` relies only on `unique_key` (`seller_id`) and `check_cols` matching against the current open row — not on `dbt_scd_id` or `dbt_valid_from`.

- **This sits outside normal CI/CD** as a manual, deliberately-triggered operation via `dbt run-operation`, rather than something that runs automatically with `dbt run` or `dbt build`. That's by design — this is a one-time historical correction, not an ongoing pipeline step.