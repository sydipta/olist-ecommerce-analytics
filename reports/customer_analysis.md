# Customer Analysis

## Scope and Definitions
- **Period:** Jan 2017 – Aug 2018, delivered orders. Customers are identified by `customer_unique_id` (`customer_id` is created per order and would overcount customers).
- **Repeat customer:** more than one delivered order inside the period. Customers whose second order fell outside the window count as one-time.
- **RFM:** Recency (days from last order to 2018-09-01), Frequency (orders) and Monetary (product spend). Recency and monetary are scored 1–5 with NTILE (5 = best); frequency is scored 1–3 (1, 2, 3+ orders) because 97% of customers have one order.
- Queries: `sql/business_analysis/04_customer_analytics.sql` (Q1–Q3)

## 1. Repeat Purchase Rate
- 93,104 customers, of which **2,789 (3.00%)** ordered more than once.
- About 97% of customers bought only once, so growth came from acquiring new customers, not from repeat purchases.

## 2. Contribution of Repeat Customers
| Group | Customers | Sales | % of sales | Avg sales per customer |
|---|---|---|---|---|
| One-time | 90,315 | R$12.46M | 94.50% | R$137.91 |
| Repeat | 2,789 | R$0.73M | 5.50% | R$260.08 |
- Repeat customers are 3% of customers but 5.5% of sales, and each spends about 1.9 times as much.

## 3. RFM Segments
| Segment | Customers | % of customers | Total spend | Avg spend |
|---|---|---|---|---|
| Recent big spenders | 14,441 | 15.51% | R$3.86M | R$267.06 |
| Repeat customers | 2,789 | 3.00% | R$0.73M | R$260.08 |
| Regular | 39,628 | 42.56% | R$3.54M | R$89.44 |
| Lapsed | 36,246 | 38.93% | R$5.05M | R$139.46 |
- Segment rules (first match wins): repeat customers (f_score ≥ 2); recent big spenders (r_score ≥ 4 and m_score ≥ 4); lapsed (r_score ≤ 2); everything else is regular.
- Recent big spenders are 15.5% of customers but 29.3% of spend.
- Lapsed customers hold 38% of spend. Because most customers bought once, this mostly means "last order was long ago".

## 4. Insights and Recommendations
1. **Retention is the main gap.** Only 3% of customers return. This fits the flat 2018 sales (see the sales analysis), though the data can't show why customers did not return.
2. **Protect the recent big spenders.** They are a small group with high spend. Recommendation: target them with follow-up offers to turn a second purchase into a habit.
3. **Test a reactivation campaign for lapsed customers.** 36k past buyers hold R$5M in historical spend.
4. **Combine with the review findings.** Customers with late deliveries leave much lower reviews (see the review analysis), which may reduce repeat purchases. This is a hypothesis to test, not a result.
5. **Caveat:** NTILE splits ties by position, so customers with identical spend can land in different score groups at the boundaries. Segment totals are barely affected.