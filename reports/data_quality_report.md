# Olist E-commerce Data Quality Assessment

## 1. Dataset Overview

**Dataset:** Brazilian E-Commerce Public Dataset by Olist  
**Source:** Kaggle  
**Database:** PostgreSQL (`olist_ecommerce`)  
**Total tables:** 9  
**Order purchase date range:** September 4, 2016 – October 17, 2018

### Objective

Evaluate the completeness, uniqueness, validity, and relational consistency of the Olist e-commerce dataset before performing business analysis.

The assessment aims to identify potential data-quality issues that could affect revenue calculations, customer behavior analysis, delivery performance metrics, and customer satisfaction insights.

## 2. Data Quality Assessment Methodology

The raw CSV datasets were imported into PostgreSQL without intentionally modifying their original records.

The following dimensions were assessed:

| Dimension | Assessment |
|---|---|
| Completeness | Missing values in key analytical columns |
| Uniqueness | Duplicate records and candidate primary keys |
| Referential Integrity | Relationships between orders, customers, products, payments, reviews, and sellers |
| Validity | Data types, numeric ranges, and timestamp availability |
| Consistency | Alignment between related tables and business processes |

### Data Handling Principles

- Preserve original data in raw tables.
- Investigate anomalies before applying corrections.
- Avoid treating expected NULL values as errors.
- Apply cleaning and transformations in separate analysis-ready datasets.
- Document assumptions and limitations affecting business KPIs.

## 3. Data Quality Findings

### 3.1 Orders

**Total records:** 99,441  
**Unique order IDs:** 99,441

| Finding | Affected Records |
|---|---:|
| Missing purchase timestamps | 0 |
| Missing approval timestamps | 160 |
| Missing carrier delivery timestamps | 1,783 |
| Missing customer delivery timestamps | 2,965 |
| Missing estimated delivery timestamps | 0 |
| Orders without matching order items | 775 |

Of the 775 orders without order items, 603 were marked unavailable, 164 canceled, and 8 had other statuses.

**Interpretation:** Missing delivery timestamps may be expected for orders that were canceled, unavailable, or not yet delivered. These records require status-aware handling rather than automatic deletion.

### 3.2 Customers

**Total records:** 99,441  
**Unique customer IDs:** 99,441  
**Unique customer identifiers (`customer_unique_id`):** 96,096

No NULL values were identified in the checked customer columns. All orders had matching customer records.

**Interpretation:** `customer_id` identifies an order-associated customer record, while `customer_unique_id` supports customer-level purchasing behavior analysis.

### 3.3 Order Items

**Total records:** 112,650  
**Distinct orders represented:** 98,666

All `(order_id, order_item_id)` combinations were unique.

- Product price range: R$0.85–R$6,735.00
- Freight value range: R$0.00–R$409.68
- No NULL values identified in the checked columns
- All order items matched existing orders, products, and sellers

**Interpretation:** The table has item-level granularity. Joining it directly with other one-to-many tables may inflate aggregate metrics.

### 3.4 Order Payments

**Total records:** 103,886  
**Distinct orders represented:** 99,440

All `(order_id, payment_sequential)` combinations were unique.

- Payment value range: R$0.00–R$13,664.08
- No NULL values identified
- One delivered order had no matching payment record
- No payment records referenced nonexistent orders

**Interpretation:** Multiple payment records may exist for a single order. Payment values must be aggregated at the appropriate level before joining with item-level data.

### 3.5 Products

**Total records:** 32,951  
**Unique product IDs:** 32,951

| Finding | Affected Records |
|---|---:|
| Missing product categories | 610 |
| Missing product weights | 2 |
| Missing product dimensions (each dimension column) | 2 |

- 73 distinct product categories were observed.
- Some products had zero recorded weight, including products that appeared in actual orders.

**Interpretation:** Missing categories affect category-level reporting. Missing or zero weights may affect logistics analysis but should not be replaced without supporting evidence.

### 3.6 Order Reviews

**Total records:** 99,224  
**Distinct review IDs:** 98,410  
**Distinct reviewed orders:** 98,673

- Exact duplicate rows: 0
- `(review_id, order_id)` combinations were unique
- Review scores ranged from 1 to 5
- No NULL review scores
- All reviewed orders matched existing orders

**Interpretation:** `review_id` alone cannot uniquely identify rows in this dataset. A composite primary key was established using `(review_id, order_id)`.

### 3.7 Product Category Translation

**Total records:** 71  
**Unique Portuguese category names:** 71  
**Missing English translations:** 0

**Interpretation:** The translation table is internally complete for its 71 entries. However, the products table contains 73 distinct category names, so translation coverage must be assessed before English-language category reporting.

### 3.8 Sellers and Geolocation

Both datasets were successfully imported into PostgreSQL.

- All order-item seller IDs matched existing seller records.
- Geolocation data contains repeated ZIP code prefixes, so ZIP prefix alone is not a suitable primary key.

**Assessment limitation:** Detailed row counts, missing-value summaries, and geographic validity findings have not yet been consolidated into this report.

## 4. Data Quality Issue Register

Issues are classified using the following severity levels:

- **High:** May materially distort business KPIs or analytical conclusions.
- **Medium:** Affects specific analyses or requires documented handling.
- **Low:** Limited impact or expected missingness.

| ID | Finding | Severity | Business Impact | Recommended Action |
|---|---|---|---|---|
| DQ-01 | 775 orders have no matching order items | Medium | Order counts and item-based revenue cover different populations | Retain orders; document exclusions from item-based metrics |
| DQ-02 | One delivered order has no payment record | Medium | Payment-based revenue may be incomplete | Flag and investigate; do not assume payment was zero |
| DQ-03 | Review IDs repeat across different orders | Medium | Incorrect review joins may duplicate or misattribute records | Use the verified composite key; assess join cardinality |
| DQ-04 | 610 products have missing categories | Medium | Category revenue may be understated if missing products are excluded | Retain and label as Unknown in analytical outputs |
| DQ-05 | Some products have zero or missing weights | Low | Product-weight and logistics analyses may be affected | Flag invalid or unavailable measurements |
| DQ-06 | Delivery and approval timestamps contain NULLs | Low | Can distort delivery-duration metrics if not handled correctly | Apply status-aware filtering |
| DQ-07 | Products contain 73 categories, while the translation table contains 71 entries | Medium | Some categories may not receive English labels | Verify category matching and provide fallback labels |
| DQ-08 | Geolocation ZIP prefixes repeat | Medium | Direct ZIP-based joins can multiply rows and inflate aggregates | Prepare a location-level lookup before joining |

**Note:** Severity reflects potential analytical impact, not necessarily errors in the original source data.

## 5. Data Treatment Decisions

### 5.1 Preserve the Raw Data

All original records will remain available in the PostgreSQL raw tables. Cleaning and transformation logic will be implemented separately to maintain traceability and reproducibility.

### 5.2 Order and Revenue Handling

- Preserve all orders for order-status and operational analysis.
- Define eligible order statuses explicitly for each revenue metric.
- Aggregate payments to the order level before joining with order items.
- Avoid combining multiple one-to-many tables without controlling join cardinality.
- Document differences between payment-based revenue, item sales value, and freight charges.

### 5.3 Missing Values

- Do not automatically replace missing timestamps with estimated values.
- Treat missing delivery dates according to order status and analytical purpose.
- Group missing product categories under an explicit Unknown label in reporting.
- Exclude missing or invalid product weights only from analyses requiring reliable weight measurements.

### 5.4 Reviews and Customer Satisfaction

- Preserve review records using `(review_id, order_id)` as the composite primary key.
- Use order-level aggregation or an explicitly defined review grain when combining reviews with order-level metrics.
- Retain valid ratings even when review comments are missing.
- Do not assume repeated review IDs represent exact duplicate rows.

### 5.5 Geolocation and Category Translation

- Do not join raw geolocation records directly to orders using ZIP prefixes.
- Create an appropriately deduplicated geographic lookup if geographic analysis requires it.
- Validate translation coverage and retain original Portuguese labels when English translations are unavailable.

### 5.6 Reproducibility

Any transformation applied during analysis must be documented in SQL scripts or Python notebooks. Derived datasets should be reproducible from the original PostgreSQL tables.

## 6. Data Readiness & Limitations

### 6.1 Overall Assessment

**Status: Conditionally ready for business analysis**

All nine Olist datasets have been imported into PostgreSQL. Initial quality assessments identified no major structural issues preventing exploratory analysis.

However, several data-quality findings require documented treatment during KPI development and analytical modeling.

### 6.2 Known Limitations

| Area | Limitation | Analytical Implication |
|---|---|---|
| Revenue | Payment and order-item records have different granularities | Revenue definitions and aggregation methods must be established before KPI calculations |
| Orders | 775 orders have no matching order items | Item-based analysis does not cover every order |
| Customer behavior | Customer records use both order-associated and unique customer identifiers | Repeat purchase analysis must use `customer_unique_id` |
| Reviews | Multiple review records can relate to an order | Review joins require cardinality checks |
| Products | Missing categories and product measurements | Category and logistics analysis may have incomplete coverage |
| Delivery | Some delivery timestamps are missing | Delivery metrics require status-aware filtering |
| Geography | ZIP prefixes repeat across geolocation records | Geographic lookup preparation is required |
| Time coverage | Dataset covers a historical period ending in 2018 | Findings should not be presented as current Olist business performance |

### 6.3 Outstanding Validation

Before publishing final analytical results, the following checks remain:

- Verify English translation coverage for product categories.
- Review geolocation completeness and coordinate validity.
- Confirm KPI-specific order status and revenue definitions.
- Validate row counts and aggregation results after analytical joins.

These checks will be performed when preparing the relevant analysis-ready datasets rather than repeating the full raw-data assessment.

### 6.4 Conclusion

The Olist dataset is suitable for exploratory business analysis, subject to the documented limitations.

The next project phase will focus on developing reproducible SQL transformations and business KPIs covering sales performance, customer behavior, product performance, delivery operations, and customer satisfaction.

All analytical assumptions and exclusions will be documented alongside their corresponding SQL scripts.