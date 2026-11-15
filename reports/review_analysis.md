# Review Analysis: Impact of Late Delivery on Customer Satisfaction

## Scope and Definitions
- **Period:** Jan 2017 – Aug 2018, delivered orders with a recorded delivery date and a review (95,560 orders).
- **Late order:** delivered on a later calendar day than the estimated delivery date (same definition as the delivery analysis).
- **Low review:** a review score of 1 or 2.
- Queries: `sql/business_analysis/03_review_analytics.sql` (Q1–Q3)

## Data Preparation
- 547 of 98,673 reviewed orders (0.55%) have more than one review.
- Rule: keep only the **latest review per order** (by `review_answer_timestamp`), so every order is counted once.
- Delivered orders without a review (643) are excluded.

## 1. Late vs On-Time Orders
- Late orders average **2.27 stars** against **4.29** for on-time orders.
- **62.42%** of late orders get a 1–2 star review, against **9.25%** of on-time orders, about **6.7 times as likely**.

## 2. Effect of the Size of the Delay
| Delay | Orders | Avg review | Low reviews |
|---|---|---|---|
| On time | 89,182 | 4.29 | 9.25% |
| 1–3 days late | 1,851 | 3.29 | 32.14% |
| 4–7 days late | 1,748 | 2.10 | 67.68% |
| 8+ days late | 2,779 | 1.70 | 79.27% |

- Satisfaction falls with every step. Even a short delay of 1–3 days costs about a full star.
- After 4+ days late, two thirds or more of customers leave a low review.
- The 8+ day group is the largest group of late orders (44%).

## 3. Insights and Recommendations
1. **Late delivery is strongly associated with low reviews.** The gap of about 2 stars is the largest satisfaction difference in the data.
2. **Reducing severe delays matters most.** Orders 8+ days late are 2.9% of all orders but 44% of late orders. Recommendation: prioritise detecting and escalating orders that are at risk of a long delay.
3. **Combine with the delivery findings.** Lateness is concentrated in RJ, the northeast and peak months (see the delivery analysis), so fixing those regions and periods gives the biggest improvement in reviews.
4. **Caveat:** this shows an association, not proof of cause. Other factors, such as product quality, may also affect reviews. A statistical test is planned in the Python stage.