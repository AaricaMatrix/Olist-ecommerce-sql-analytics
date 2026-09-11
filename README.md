# Olist E-Commerce Sales & Customer Analytics

A PostgreSQL and SQL analytics project built using the **Brazilian E-Commerce Public Dataset by Olist**.

The project analyzes approximately 100K orders and related customer, product, seller, payment, review, delivery, and geographic data to answer practical business questions.

## 🎯 Project Objective

The objective is to transform raw e-commerce transaction data into actionable business insights using SQL.

Key analysis areas include:

- 📈 Sales and revenue trends
- 🛍️ Product and category performance
- 🏆 Seller performance
- 👥 Customer behavior and repeat purchasing
- 💳 Payment methods and installments
- 🚚 Delivery performance
- ⭐ Customer review analysis
- 🌎 Geographic performance
- 📊 Advanced SQL analytics

## 🛠️ Tech Stack

- **PostgreSQL**
- **pgAdmin 4**
- **SQL**
- **Git & GitHub**

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

### Main Relationships

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

The PostgreSQL database was created and populated with the Olist dataset.

![Database Overview](screenshots/database_overview.png)

## ✅ Data Validation

All 9 tables were loaded and validated using PostgreSQL row-count checks.

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

Orders were grouped by status to understand the order lifecycle.

![Order Status Analysis](screenshots/order_status_analysis.png)

### Orders by Customer State

A JOIN between `customers` and `orders` was used to analyze order volume across Brazilian states.

![Orders by Customer State](screenshots/orders_by_state.png)

## 📈 Business Analysis

### Sales & Revenue
- Total product revenue
- Freight value
- Average order value
- Monthly revenue trends
- Monthly order trends
- Revenue growth

### Product & Category
- Revenue by category
- Top revenue-generating categories
- Top products
- Units sold by category

### Seller Performance
- Top sellers by revenue
- Top sellers by order volume
- Seller performance by state
- Seller revenue concentration

### Customer Analytics
- Unique customers
- Orders per customer
- Repeat customer rate
- Customer revenue
- Customer segmentation
- Customer ranking
- Customer revenue concentration
- Cohort-style analysis

### Payment Analytics
- Payment method usage
- Payment value share
- Installment distribution
- Average payment value

### Delivery Analytics
- Average delivery time
- On-time vs late delivery
- Average days vs estimated delivery
- Delivery performance by state
- Delivery-time buckets

### Review Analytics
- Review score distribution
- Average review score
- Review score vs delivery status
- Category-level review performance

### Geographic Analytics
- Orders by customer state
- Revenue by customer state
- Seller revenue by state

## 🧠 Advanced SQL Techniques

The project demonstrates:

- `JOIN`
- `GROUP BY`
- Aggregate functions
- `CASE`
- `FILTER`
- Common Table Expressions (CTEs)
- `LAG()`
- `RANK()`
- `DENSE_RANK()`
- `NTILE()`
- Window functions
- Cumulative revenue
- Revenue share
- Customer segmentation
- Cohort-style analysis
- Percentiles
- Analytical views
- Data-quality checks

## 📊 Key KPI Framework

The project tracks core e-commerce KPIs including:

- Total orders
- Unique customers
- Product revenue
- Freight value
- Average order value
- Average review score
- Delivered orders
- On-time delivery rate
- Repeat customer rate
- Revenue concentration

## 📁 Repository Structure

```text
Olist_Ecommerce_SQL_Project/
│
├── README.md
├── .gitignore
│
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_analysis_queries.sql
│   ├── 03_advanced_analysis.sql
│   └── 04_analytical_views.sql
│
└── screenshots/
    ├── database_overview.png
    ├── database_validation.png
    ├── order_status_analysis.png
    └── orders_by_state.png
```

## 📂 Dataset

The project uses the **Brazilian E-Commerce Public Dataset by Olist**.

The original CSV files are not included in this repository.

## 🚀 Project Highlights

- Designed a relational PostgreSQL database with 9 tables.
- Loaded and validated more than 1 million records across the dataset.
- Built SQL analyses covering sales, customers, products, sellers, payments, delivery, reviews, and geography.
- Applied advanced SQL techniques including CTEs and window functions.
- Created reusable analytical views for order, category, seller, and customer performance.

---

**Built with PostgreSQL and SQL for data analytics and business intelligence.**
