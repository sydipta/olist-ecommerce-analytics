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