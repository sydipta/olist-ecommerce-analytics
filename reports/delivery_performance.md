# Delivery Performance Analysis

## Scope and Definitions
- **Period:** Jan 2017 – Aug 2018, delivered orders with a recorded delivery date.
- **Late order:** delivered on a later calendar day than the estimated delivery date.
- **Delivery days:** purchase date to customer delivery date. **Estimated days:** purchase date to estimated delivery date.
- Queries: `sql/business_analysis/02_delivery_performance.sql` (Q-a, Q-b, Q-c)

## 1. Overall Performance
- 96,203 delivered orders: average delivery **12.48 days** against **24.28 days** promised.
- Only **6,531 orders (6.79%)** arrived late.
- Estimates are conservative: orders typically arrive about 12 days before the promised date.

## 2. Trend Over Time
- Late percentage was 3–6.5% in most months.
- Three months stand out: **Nov 2017 (12.40%)**, **Feb 2018 (14.13%)** and **Mar 2018 (18.96%, 1,328 late orders, the worst month)**.
- Nov 2017 coincides with the Black Friday peak (7,288 delivered orders). Mar 2018 had normal volume (7,003 orders), so volume alone doesn't explain it.
- From Jun 2018, average delivery time fell to under 9 days and late orders dropped to 1.16% in Jun 2018, though Olist's estimates also fell, from 28 to 16 days.

## 3. Delivery by State
(States with 500+ delivered orders only; 17 states.)
- **Best:** PR (4.06% late), SP (4.50%, 8.7 days average) and MG (4.59%).
- **Worst:** MA (17.53%), CE (13.83%), BA (12.17%), PA (11.25%) and PB (10.47%).
- **RJ is the biggest single problem:** 12.14% late on 12,310 orders, about 23% of all late orders, even though it is not a remote state (15.2 days average).
- **Slow is not the same as late:** PA is the slowest state (23.7 days) but only 11.25% late, because its estimate is 37.7 days. RJ is faster but later more often, because its estimate is tighter (26.9 days).

## 4. Insights and Recommendations
1. **Overall delivery is strong**, but lateness is concentrated in specific months and states.
2. **Fix RJ and the northeast first.** They account for a large share of late orders. Recommendation: review carrier performance and estimates for these regions.
3. **Set estimates by region.** Padded estimates hide slow delivery in the north, while tight ones in RJ create lateness. Recommendation: calibrate estimates per state.
4. **Peak periods are the risk.** Nov 2017 and Feb–Mar 2018 had the worst lateness. Recommendation: plan carrier capacity before peaks; the causes of the 2018 spike need further investigation.
5. **Caveat:** states with fewer than 500 orders were excluded, and the most recent months only include orders already delivered.