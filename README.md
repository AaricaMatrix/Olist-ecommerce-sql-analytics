# Olist E-Commerce Sales & Customer Analytics

A PostgreSQL and SQL analytics project using the **Brazilian E-Commerce Public Dataset by Olist** to analyze orders, customers, products, sellers, payments, reviews, and delivery performance.

## 📌 Project Overview

This project uses PostgreSQL to transform a large e-commerce dataset into meaningful business insights.

The analysis will focus on:

- 📈 Sales and revenue trends
- 🛍️ Product and category performance
- 🏆 Seller performance
- 👥 Customer behavior
- 💳 Payment methods and installments
- 🚚 Delivery performance
- ⭐ Customer reviews
- 🌎 Geographic order distribution

## 🛠️ Tech Stack

- **Database:** PostgreSQL
- **SQL Tool:** pgAdmin 4
- **Version Control:** Git & GitHub
- **Dataset:** Brazilian E-Commerce Public Dataset by Olist

## 🗄️ Database Structure

The database contains 9 tables:

```text
customers
orders
order_items
products
sellers
order_payments
order_reviews
geolocation
product_category_translation
```

Main relationships:

```text
CUSTOMERS
    │
    │ customer_id
    ▼
 ORDERS
    │
    ├──────────────► ORDER_ITEMS ──────────► PRODUCTS
    │                     │
    │                     └────────────────► SELLERS
    │
    ├──────────────► ORDER_PAYMENTS
    │
    └──────────────► ORDER_REVIEWS

PRODUCTS ─────────► PRODUCT_CATEGORY_TRANSLATION

GEOLOCATION
```

## 📊 Database Overview

The PostgreSQL database and all 9 tables were successfully created and populated.

![Database Overview](screenshots/database_overview.png)

## ✅ Data Validation

The imported data was validated by checking the row count of every table.

![Database Validation](screenshots/database_validation.png)

| Table | Row Count |
|---|---:|
| customers | 99,441 |
| geolocation | 1,000,163 |
| order_items | 112,650 |
| order_payments | 103,886 |
| order_reviews | 99,224 |
| orders | 99,441 |
| product_category_translation | 71 |
| products | 32,951 |
| sellers | 3,095 |

## 🔎 Initial SQL Analysis

### Order Status Distribution

The first analysis groups orders by their current status to understand the overall order lifecycle.

![Order Status Analysis](screenshots/order_status_analysis.png)

### Orders by Customer State

A SQL JOIN between `customers` and `orders` was used to analyze order volume across Brazilian states.

![Orders by Customer State](screenshots/orders_by_state.png)

## 📈 Planned Analysis

The project will be developed further with the following analysis:

### Sales & Revenue
- Total revenue
- Monthly revenue trends
- Average order value
- Revenue by product category
- Revenue by state

### Product & Seller Analysis
- Top-selling products
- Top revenue-generating categories
- Top-performing sellers
- Seller order volume

### Customer Analysis
- Unique customers
- Repeat customers
- Customer order frequency
- Customer distribution by state

### Payment Analysis
- Most-used payment methods
- Revenue by payment type
- Installment analysis

### Delivery Analysis
- Average delivery time
- On-time vs late deliveries
- Delivery performance by state
- Estimated vs actual delivery

### Review Analysis
- Review score distribution
- Average review score
- Review score vs delivery performance

### Advanced SQL
- CTEs
- Window functions
- Ranking
- Customer segmentation
- Cohort analysis
- Analytical views

## 📁 Repository Structure

```text
Olist_Ecommerce_SQL_Project/
│
├── README.md
├── .gitignore
│
├── sql/
│   ├── 01_create_tables.sql
│   └── 02_analysis_queries.sql
│
└── screenshots/
    ├── database_overview.png
    ├── database_validation.png
    ├── order_status_analysis.png
    └── orders_by_state.png
```

## 📂 Dataset

The original Olist CSV files are **not included in this repository**.

The project uses the Brazilian E-Commerce Public Dataset by Olist.

## 🚀 Project Status

- [x] PostgreSQL database created
- [x] 9 database tables created
- [x] Dataset imported
- [x] Data validation completed
- [x] Initial SQL analysis completed
- [ ] Sales & revenue analysis
- [ ] Product/category analysis
- [ ] Seller analysis
- [ ] Customer analysis
- [ ] Payment analysis
- [ ] Delivery analysis
- [ ] Review analysis
- [ ] Advanced SQL analysis
- [ ] Final business insights

---

**Built with PostgreSQL and SQL for data analytics and business intelligence.**
