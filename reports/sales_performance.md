# Sales Performance Analysis

## Scope and Definitions
- **Period:** Jan 2017 – Aug 2018 (20 months). 2016 excluded due to sparse data.
- **Sales:** sum of product price (excluding freight) for delivered orders, grouped by purchase month.
- **AOV:** product sales / completed orders.
- Queries: `sql/business_analysis/01_sales_performance.sql` (Q1–Q4b)

## 1. Monthly Trend
- Sales grew from R$111,798 (750 orders) in Jan 2017 to R$648,248 (4,478 orders) in Oct 2017.
- Nov 2017 was the peak month: R$987,765 from 7,289 orders.
- In 2018, sales plateaued between R$826k and R$978k per month and never returned to the Nov 2017 peak.

## 2. Month-over-Month Growth
- **Strongest:** Nov 2017 (+52.37%), driven by Black Friday (7,289 orders in the month, 1,147 on Nov 24 alone). Early-2017 growth (e.g. Feb +109.5%) reflects a very small base.
- **Weakest:** Dec 2017 (−26.50%), the post-Black Friday drop. Jun 2018 (−12.43%) and Feb 2018 (−10.62%) were the next weakest.
- From Apr 2018 onward, most months moved within about ±3%, consistent with a plateau.

## 3. Volume vs AOV
- AOV stayed within R$124–R$149 across all 20 months, while monthly orders rose from 750 to over 7,000.
- In Nov 2017: sales +52.37%, orders +62.77%, AOV −6.39%.
- **Takeaway:** growth came from more orders, not from larger baskets.

## 4. Year-over-Year Growth
- **Jan–Aug comparison:** product sales were R$2,993,456 in Jan–Aug 2017 and R$7,218,125 in Jan–Aug 2018, a **+141.13%** increase.
- **Monthly YoY fell steadily through 2018:** +727% (Jan), +253% (Feb), +165% (Mar), +186% (Apr), +100% (May), +103% (Jun), +80% (Jul), +51% (Aug).
- **Why it shrinks:** early-2017 months were a very small base, since the business was still ramping up. 2018 monthly sales were roughly flat at R$0.83M–R$0.98M, so each month is compared against a larger 2017 month.
- **Takeaway:** the business scaled strongly in 2017 and then plateaued in 2018. YoY growth is still positive, but the high percentages are mostly a base effect.

## 5. Key Insights and Recommendations
1. **Growth was volume-driven.** AOV stayed in a narrow R$124–R$149 band, so order count drives sales. Recommendation: test AOV levers such as bundles, free-shipping thresholds and cross-sell, since volume alone has plateaued.
2. **Black Friday is a concentrated spike.** Nov 2017 sales were +52% over October, followed by −26.5% in December. Recommendation: plan inventory and delivery capacity for November, and run post-peak campaigns to soften the December drop.
3. **2018 has plateaued.** Monthly sales stayed flat from January to August. Recommendation: investigate whether the cause is customer acquisition or repeat purchases (next module: customer analytics).