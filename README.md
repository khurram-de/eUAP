# 🛍️ E-Commerce Unified Analytics Platform (eUAP)

A modern analytics engineering project built with **dbt** and **Snowflake**, modeling the [Olist E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) into a unified analytics platform.

---

## 🚀 Project Overview
This project simulates an end-to-end e-commerce analytics platform with a **Bronze–Silver–Gold** layer architecture:
- **Bronze (Staging):** Raw tables cleaned and standardized.
- **Silver (Intermediate):** Business logic transformations and joins across domains.
- **Gold (Marts):** Aggregated models for KPIs like Sales, Revenue, Delivery Performance, and Customer Cohorts.

---

## 🧱 Tech Stack
- **dbt Core / dbt Cloud**
- **Snowflake**
- **GitHub + VS Code**
- **(Optional)** Power BI / Streamlit for visualization

---

## 🧩 Key Models
| Layer | Folder | Description |
|--------|---------|-------------|
| Staging | `models/staging/` | Raw source data cleaned and standardized |
| Intermediate | `models/intermediate/` | Domain-level joins and enrichments |
| Marts | `models/marts/` | Final reporting models and KPIs |

---

## 📈 Example KPIs
- Total Orders & Revenue by Month  
- Average Delivery Time vs Estimated Time  
- Repeat Customer Rate  
- Seller Performance  
- Category Growth & Trends  

---

## 🗂️ Folder Structure
```
eUAP/
├── models/
│   ├── staging/
│   ├── intermediate/
│   └── marts/
├── macros/
├── snapshots/
├── tests/
├── 01_Business_Context.md
├── ERD_Diagram_from_dbdiagram_io.txt
├── ERD_Diagram.png
├── dbt_project.yml
└── README.md
```


---

## 🧠 Author
**Khurram Hayat Khan**  
_Data Engineer @ Teradata_  
**Tech Stack:** Snowflake · Apache Spark · AWS · dbt · Airflow  
🔗 [LinkedIn](https://www.linkedin.com/in/mkhurramhk/)

---

## 📚 References
- [dbt Documentation](https://docs.getdbt.com/)
- [Snowflake Docs](https://docs.snowflake.com/)
- [Olist Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
