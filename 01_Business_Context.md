# 📘 01_Business_Context  
### *E-Commerce Unified Analytics Platform (E-UAP)*

---

## 1️⃣ Background

The company operates a **marketplace e-commerce platform** similar to *Olist*, connecting **independent sellers** with **customers** across Brazil.  
Operational data is collected daily from multiple domains — orders, payments, logistics, and customer reviews.

Until now, analytics has relied on **manual spreadsheets** and **department-specific SQL reports**, resulting in:
- Inconsistent definitions of KPIs (e.g., “Revenue” vs. “Collected Payments”).
- Fragmented visibility into the **end-to-end customer journey**.
- Slow, manual reporting cycles that delay strategic decisions.

The business leadership has mandated the creation of a **unified analytics platform** to centralize all e-commerce data, enforce data quality, and provide a consistent metric layer across departments.

---

## 2️⃣ Problem Statement

Current analytical workflows suffer from:
- **Data fragmentation:** order, payment, and review data live in separate silos.  
- **Metric inconsistency:** multiple teams maintain different logic for the same KPI.  
- **No historical tracking:** updates (cancellations, refunds, delayed deliveries) overwrite old values.  
- **Manual refreshes:** no automated ingestion or transformation processes.  
- **Limited trust:** business teams doubt dashboard accuracy due to unclear data lineage.

---

## 3️⃣ Business Objective

To design and implement an **E-Commerce Unified Analytics Platform (E-UAP)** that delivers:

1. A **single source of truth** for operational and financial metrics.  
2. End-to-end visibility from **order placement → payment → fulfillment → review**.  
3. Consistent **definitions, KPIs, and metadata governance**.  
4. Automated, incremental data pipelines built on **Snowflake + dbt**.  
5. A scalable foundation for advanced analytics and machine-learning use cases.

---

## 4️⃣ Key Business Questions

### Customer & Order Insights
- How long does it take from purchase to delivery?  
- How does delivery performance differ by seller, state, or product category?  
- What is the conversion funnel from order → payment → delivery → review?  
- How do late deliveries affect customer satisfaction?

### Seller & Product Insights
- Which sellers contribute most to revenue and maintain high review scores?  
- What are the top-performing and most-returned product categories?  
- What are average freight costs per category or seller?

### Financial & Performance Metrics
- What is **booked revenue** (orders) vs. **realized revenue** (payments)?  
- How much revenue is “in pipeline” from unfulfilled or unpaid orders?  
- What is the refund rate and its financial impact?

---

## 5️⃣ Expected Outcomes

| Category | Outcome |
|-----------|----------|
| **Data Architecture** | Centralized data warehouse in Snowflake with layered schemas (`raw`, `staging`, `core`, `marts`). |
| **Transformation Layer** | Modular dbt models enforcing naming standards, surrogate keys, and incremental updates. |
| **Governance** | Documented metric definitions and lineage; dbt tests for quality and integrity. |
| **Automation** | Orchestrated pipelines (Airflow / dbt Cloud / Prefect) for daily refreshes. |
| **Analytics** | Power BI dashboards for revenue, fulfillment, and customer satisfaction metrics. |

---

## 6️⃣ Stakeholders & Responsibilities

| Role | Responsibility |
|------|----------------|
| **Data Engineering Team** | Design schemas, build dbt models, maintain pipelines and data quality. |
| **Data Analysts** | Develop dashboards and ensure KPI alignment with the metric charter. |
| **Business Teams (Sales, Ops, CX)** | Consume unified datasets for reporting and strategic planning. |
| **Platform Owner (Project Lead)** | Maintain documentation, oversee data governance, and ensure business alignment. |

---

## 7️⃣ Success Metrics

| Category | Target |
|-----------|---------|
| **Data Freshness** | Daily ingestion completed by 08:00 AM local time. |
| **Data Accuracy** | < 1 % discrepancy between operational source and Snowflake tables. |
| **Performance** | 95 % of KPI queries execute in < 20 seconds. |
| **Adoption** | 100 % of business reporting migrated to unified platform. |

---

## 8️⃣ Long-Term Vision

The E-UAP will evolve into a **data-as-a-service platform**, integrating predictive analytics and AI-driven insights such as:
- Delivery delay forecasting.  
- Customer lifetime value (CLV) modeling.  
- Seller performance scoring and recommendation systems.

---

## 9️⃣ Summary

The E-Commerce Unified Analytics Platform aims to transform raw transactional data into trusted business intelligence.  
By standardizing data models, automating workflows, and exposing reliable metrics, the company will move from reactive reporting to **proactive, data-driven decision-making**.

---

