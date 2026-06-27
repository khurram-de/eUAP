# 🛍️ E-Commerce Unified Analytics Platform (eUAP)

A dbt + Snowflake analytics engineering project built on the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), designed to demonstrate production-pattern data modelling rather than a basic staging-to-dashboard pipeline.

The project is built around a deliberate constraint: there is no business stakeholder or data modeller handing down requirements. Metrics were derived through a structured three-stakeholder exercise (Sales, Operations, CX), documented in [`01_Business_Context.md`](./01_Business_Context.md), before any modelling work began.

---

## 🚀 Project Overview

eUAP follows a layered warehouse architecture:

- **Raw** — source data loaded as-is from S3 via external stage
- **Staging** — cleaned, standardised, tested source-conformed models
- **Snapshots** — dbt snapshot-based change tracking (SCD Type 2)
- **Intermediate** — enriched fact tables and dimensions with derived business logic
- **Marts** — stakeholder-facing reporting models at deliberate, defensible grains

The **Operations vertical** (fulfilment and delivery performance) is built end to end: raw → staging → snapshot → dimension → two fact tables → two marts.

---

## ⚙️ Setup

Snowflake environment objects (role, warehouse, databases, schemas, grants, external stage, raw tables, and data load) are created via the numbered SQL scripts in the repo root, intended to be run in order:

1. [`02_a_Creating_Snowflake_Enviroment_Objects.sql`](./02_a_Creating_Snowflake_Enviroment_Objects.sql) — role, warehouse, `RAW` and `ANALYTICS` databases/schemas, grants
2. [`02_b_Creating_External_Stage_using_AWS_s3.sql`](./02_b_Creating_External_Stage_using_AWS_s3.sql) — S3 storage integration and external stage
3. [`02_c_Raw_Layer_Table_Creation.sql`](./02_c_Raw_Layer_Table_Creation.sql) — raw layer table DDL
4. [`02_d_Copying_Data_Into_Raw_Tables_From_External_Stage.sql`](./02_d_Copying_Data_Into_Raw_Tables_From_External_Stage.sql) — `COPY INTO` statements loading the Olist CSVs from S3

[`snowflake_env_setup.sql`](./snowflake_env_setup.sql) is also in the repo and covers similar environment setup ground — kept as-is for reference.

Once raw data is loaded, run `dbt deps`, then `dbt build` to run staging, snapshots, intermediate, and mart models.

---

## 🧠 Notable Design Decisions

A few choices in this project were made deliberately, not by default:

- **Grain discipline** — `fct_orders` (one row per order) and `fct_order_items` (one row per order item) are kept as two separate fact tables. An earlier version joined order items directly into `fct_orders`, which silently fanned out and double-counted order-level metrics whenever an order had items from multiple sellers.

- **SCD Type 2 seller dimension** — `dim_sellers` is built on top of a dbt snapshot (`sellers_snapshot`), tracking seller city/state/zip changes over time. `fct_order_items` joins to it using a **temporal join** (`order_purchase_timestamp BETWEEN dbt_valid_from AND dbt_valid_to`) so each order matches the seller version that was actually valid at the time it was placed.

- **A real backfill bug, fully diagnosed** — dbt snapshots only record `dbt_valid_from` from the date the snapshot is *first run*, not any true historical date. Run against a multi-year-old static dataset, this meant every temporal join returned NULL. Diagnosed from first principles and fixed with a one-time `dbt run-operation` macro that backfills `dbt_valid_from` using each seller's actual first order date.

- **Derived business logic lives in the fact table, not the mart** — `is_on_time`, delivery stage durations, and order status categorisation are computed once in `fct_orders`, using the test: *would more than one stakeholder need this exact definition?* Operations and CX both need on-time status, so it's calculated once and reused, rather than duplicated and risking drift across marts.

- **Two marts, two grains, on purpose** — `mart_fulfilment` (grain: week × customer state) and `mart_fulfilment_by_seller` (grain: week × seller state) are kept independent rather than merged, because combining customer-region and seller-region in one table would fan out on multi-seller orders. The seller-region mart pre-deduplicates `fct_order_items` down to distinct `(order_id, seller_state)` pairs before aggregating, to avoid the same fan-out problem one level up.

- **Schema drift handled deliberately, not by default** — incremental models use `on_schema_change: append_new_columns` for additive changes. `sync_all_columns` is explicitly avoided since it can silently drop columns that downstream consumers still depend on.

---

## 🧱 Tech Stack

- **dbt Core**
- **Snowflake**
- **AWS S3** (external stage for raw data loading)
- **GitHub + VS Code**

---

## 🧩 Key Models

| Layer | Folder | Description |
|--------|---------|-------------|
| Staging | `models/staging/` | Source-conformed models, tested for nulls/uniqueness/accepted values |
| Snapshots | `snapshots/` | SCD Type 2 change tracking (`sellers_snapshot`) |
| Intermediate | `models/intermediate/` | Enriched fact tables and dimensions (`fct_orders`, `fct_order_items`, `dim_sellers`) |
| Marts | `models/mart/` | Stakeholder-facing reporting models (`mart_fulfilment`, `mart_fulfilment_by_seller`) |
| Macros | `macros/` | One-time operational macros (e.g. snapshot backfill) |

---

## 📊 Operations Vertical — Metrics Served

Derived from the Head of Operations stakeholder charter:

- On-Time Delivery Rate
- Delivery Stage Breakdown (purchase → approval → carrier → customer)
- Late Orders by Customer Region
- Late Orders by Seller Region
- Delivery Compliance Trend (week-over-week)

Sales and CX verticals are defined in the metric charter but not yet built.

---

## 🗂️ Folder Structure

```
eUAP/
├── models/
│   ├── staging/
│   ├── intermediate/
│   ├── mart/
│   └── analysis/
├── macros/
├── snapshots/
├── tests/
├── seeds/
├── 01_Business_Context.md
├── 02_a_Creating_Snowflake_Enviroment_Objects.sql
├── 02_b_Creating_External_Stage_using_AWS_s3.sql
├── 02_c_Raw_Layer_Table_Creation.sql
├── 02_d_Copying_Data_Into_Raw_Tables_From_External_Stage.sql
├── snowflake_env_setup.sql
├── ERD_Diagram_from_dbdiagram_io.txt
├── ERD_Diagram.png
├── dbt_project.yml
├── packages.yml
└── README.md
```

---
 
## 🚧 Status
 
**Done:**
- 3-stakeholder metric charter (Sales / Operations / CX)
- `fct_orders` and `fct_order_items` — grain-clean, enriched with derived business logic
- `dim_sellers` via SCD Type 2 snapshot, with temporal join in `fct_order_items`
- `mart_fulfilment` and `mart_fulfilment_by_seller`
- dbt tests on `fct_orders` and `fct_order_items`, plus a reconciliation test between `mart_fulfilment` and `fct_orders`

**Next:**
- CI/CD (GitHub Actions running `dbt test` on PRs)
- Orchestration (currently run manually via `dbt run` / `dbt build`)
- Sales and CX verticals

---

## 🧠 Author

**Khurram Hayat Khan**
_Senior Data Engineer @ Teradata_
**Tech Stack:** Snowflake · dbt · AWS · Apache Spark · Airflow
🔗 [LinkedIn](https://www.linkedin.com/in/mkhurramhk/)

---

## 📚 References

- [dbt Documentation](https://docs.getdbt.com/)
- [Snowflake Docs](https://docs.snowflake.com/)
- [Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)