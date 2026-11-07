# Olist E-commerce — Business Metrics Dictionary

## 1. Purpose

Define consistent business metrics for sales performance, customer behavior, delivery operations, and customer satisfaction analysis.

**Currency:** Brazilian Real (BRL)  
**Primary reporting period:** Monthly  
**Data source:** Olist PostgreSQL database

## 2. Sales Performance KPIs

| KPI | Definition | Calculation |
|---|---|---|
| Completed Product Sales Value | Total product value of delivered orders, excluding freight | Sum of `order_items.price` for delivered orders |
| Completed Orders | Number of distinct delivered orders | `COUNT(DISTINCT order_id)` for delivered orders |
| Average Order Value (AOV) | Average product sales value per completed order | Completed Product Sales Value / Completed Orders |
| Freight Charges | Total freight associated with delivered orders | Sum of `order_items.freight_value` for delivered orders |
| Total Payment Value | Total recorded payment value associated with delivered orders | Sum of order-level aggregated payments for delivered orders |
| Monthly Sales Growth | Percentage change in completed product sales compared with the previous month | `(Current Month Sales - Previous Month Sales) / Previous Month Sales × 100` |

## 3. Calculation Rules

- Include only orders with `order_status = 'delivered'` for completed-sales KPIs.
- Attribute monthly sales to `order_purchase_timestamp` (purchase cohort), not the delivery month.
- Exclude freight from product sales value and AOV.
- Count distinct orders rather than order-item rows.
- Aggregate payments by `order_id` before combining them with item-level data.
- Treat months with zero previous-month sales as undefined growth rather than dividing by zero.
- Do not interpret these metrics as audited accounting revenue.

## 4. Data Limitations

- Refunds, returns, and accounting adjustments are not fully captured.
- Payment value and product sales value may differ.
- The final months of the dataset may be incomplete.
- Purchase-month reporting of delivered orders measures completed sales by purchase cohort, not revenue recognized during that month.