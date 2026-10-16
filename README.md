# Smart E-Commerce Demand & Operations Intelligence System

An end-to-end data analytics project built with the Brazilian Olist e-commerce public dataset. The project brings together Python, SQL, machine learning, and Power BI to explore order demand, customer behavior, product performance, seller activity, delivery operations, and potential business risks.

> **Important scope note:** The project folder name includes “Smart E-Commerce”; the data is about Brazilian e-commerce, not smart-city or urban sensor demand. The forecasts are exploratory estimates from historical order counts, not a production forecasting service. Customer “churn” is represented by an inactivity-based proxy label, not a confirmed business churn outcome.

## Dataset link :- https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## Table of contents

- [1. Project at a glance](#1-project-at-a-glance)
- [2. Business problem](#2-business-problem)
- [3. Project objectives](#3-project-objectives)
- [4. Dataset](#4-dataset)
- [5. Tools and technologies](#5-tools-and-technologies)
- [6. Repository structure](#6-repository-structure)
- [7. How the project works](#7-how-the-project-works)
- [8. Setup and prerequisites](#8-setup-and-prerequisites)
- [9. Run the Python notebooks](#9-run-the-python-notebooks)
- [10. Run the SQL analysis](#10-run-the-sql-analysis)
- [11. Explore the Power BI report](#11-explore-the-power-bi-report)
- [12. Machine-learning and intelligence modules](#12-machine-learning-and-intelligence-modules)
- [13. Outputs and how to interpret them](#13-outputs-and-how-to-interpret-them)
- [14. KPI definitions](#14-kpi-definitions)
- [15. Current findings](#15-current-findings)
- [16. Limitations and validation notes](#16-limitations-and-validation-notes)
- [17. Troubleshooting](#17-troubleshooting)
- [18. Author and project status](#19-author-and-project-status)

## 1. Project at a glance

| Item | Description |
|---|---|
| Project type | End-to-end data analytics and business intelligence |
| Domain | E-commerce operations and customer/product analytics |
| Dataset | Brazilian Olist e-commerce public dataset |
| Main tools | Python, pandas, scikit-learn, MySQL, Power BI, Jupyter Notebook |
| Analysis areas | Orders, demand, customers, products, sellers, payments, reviews, delivery, anomalies |
| Main deliverable | Power BI report supported by Python notebooks, SQL scripts, charts, tables, and prediction files |

## 2. Business problem

An e-commerce business generates information across orders, customers, products, sellers, payments, reviews, and deliveries. Looking at each dataset independently makes it difficult to answer practical questions such as:

- How does order demand change over time?
- Which product categories generate the most sales revenue and units sold?
- Which states contribute the most orders and customer revenue?
- How long do deliveries take, and how often do delivered orders miss their estimated delivery date?
- What do customer purchasing patterns suggest about repeat purchasing and inactivity?
- Can historical order counts provide a useful short-term demand baseline?
- Which orders have unusual financial or operational patterns that deserve investigation?

This project combines data preparation, SQL analysis, machine learning experiments, and dashboard reporting to help explore these questions.

## 3. Project objectives

1. Load and understand the raw Olist tables.
2. Clean and standardize data types, column names, duplicate records, and selected missing values.
3. Explore the dataset with summary statistics and visualizations.
4. Create customer- and order-level features for analysis.
5. Use SQL to answer business questions and prepare analytical views.
6. Build Power BI pages that summarize business performance.
7. Experiment with demand forecasting, customer inactivity risk, and anomaly detection.
8. Store reproducible charts, tables, and prediction outputs in a structured folder.

## 4. Dataset (https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The project uses nine CSV files from the public Olist Brazilian e-commerce dataset, commonly distributed through Kaggle. The data represents orders and related marketplace activity in Brazil, primarily from 2016–2018.

| Raw file | What it contains |
|---|---|
| `olist_customers_dataset.csv` | Customer IDs and customer location fields |
| `olist_geolocation_dataset.csv` | ZIP-code-level latitude, longitude, city, and state information |
| `olist_orders_dataset.csv` | Order status and key order timestamps |
| `olist_order_items_dataset.csv` | Products, sellers, item prices, and freight for each order item |
| `olist_order_payments_dataset.csv` | Payment method, installments, and payment value |
| `olist_order_reviews_dataset.csv` | Review scores and review comments |
| `olist_products_dataset.csv` | Product categories and product attributes |
| `olist_sellers_dataset.csv` | Seller IDs and seller locations |
| `product_category_name_translation.csv` | Portuguese-to-English product category names |

The `01_Raw_Data/` folder contains the original CSV inputs. The `02_Clean_Data/` folder contains the processed versions used by later notebooks and SQL scripts. Keep raw data unchanged so cleaning can be repeated and audited.

**Data handling note:** Customer and seller identifiers are dataset identifiers, not real-world names. Avoid attempting to re-identify individuals. If you redistribute the dataset, check the source's terms and attribution requirements.

## 5. Tools and technologies

- **Python:** general analysis and automation.
- **pandas / NumPy:** data loading, cleaning, joins, grouping, and feature creation.
- **Matplotlib / Seaborn:** exploratory charts and saved visual outputs.
- **scikit-learn:** Random Forest forecasting experiment, Random Forest classification, feature scaling, and Isolation Forest anomaly detection.
- **Jupyter Notebook:** step-by-step, inspectable analysis.
- **MySQL:** relational tables, joins, aggregations, KPI queries, and Power BI-oriented views.
- **Power BI Desktop:** interactive report pages and business-facing summaries.

A typical Python environment can be prepared with:

```bash
python -m venv .venv
```

Activate it, then install the core packages:

```bash
python -m pip install --upgrade pip
python -m pip install pandas numpy matplotlib seaborn scikit-learn jupyter ipykernel
```

If you use a different Python environment, install the same packages there. The SQL scripts require a compatible MySQL server/client, and the `.pbix` report requires Power BI Desktop for full interaction.

## 6. Repository structure

```text
Smart_E-Commerce_Demand_&_Operations_Intelligence_System/
├── README.md                         # Project guide (this file)
├── 01_Raw_Data/                      # Original Olist CSV files
├── 02_Clean_Data/                    # Cleaned CSV files used downstream
├── 03_Python/
│   ├── 01_data_loading.ipynb         # Load and inspect raw datasets
│   ├── 02_data_cleaning.ipynb         # Standardize and clean data
│   ├── 03_EDA.ipynb                  # Exploratory data analysis and charts
│   └── 04_feature_engineering.ipynb   # Customer/order-level features
├── 04_SQL/
│   ├── 00_database_setup.sql         # Create schema/tables and load CSV data
│   ├── 01_basic_analysis.sql         # General order and business analysis
│   ├── 02_customer_analysis.sql      # Customer-level analysis and segments
│   ├── 03_product_analysis.sql       # Product/category performance
│   ├── 04_delivery_analysis.sql     # Delivery and operational analysis
│   ├── 05_Business_kpis.sql          # Business KPI queries
│   └── 06_powerbi_views.sql          # Views intended to support Power BI
├── 05_Power_BI/
│   └── Smart_Demand_Intelligence.pbix
├── 06_ML/
│   ├── 05_product_location_intelligence.ipynb
│   ├── 06_operations_intelligence.ipynb
│   ├── 07_demand_forecasting.ipynb
│   ├── 08_customer_churn.ipynb
│   └── 09_anomaly_detection.ipynb
├── 07_Reports/                       # Reserved for the final written report
├── 08_Presentation/                  # Reserved for the final presentation
└── 09_Outputs/
    ├── charts/                       # PNG charts generated by notebooks
    ├── tables/                       # CSV summaries and analytical tables
    └── predictions/                   # Forecasts, risk outputs, anomaly labels
```

Some notebooks save files into `09_Outputs/`. If you change the project folder name or move it to another computer, update the path variables at the beginning of each notebook (see the setup section below).

## 7. How the project works

```text
Raw Olist CSV files
        ↓
Load and inspect datasets (01_data_loading.ipynb)
        ↓
Clean and standardize data (02_data_cleaning.ipynb)
        ↓
Clean CSV files in 02_Clean_Data/
        ├──→ Exploratory analysis and charts (03_EDA.ipynb)
        ├──→ Customer/order features (04_feature_engineering.ipynb)
        ├──→ MySQL tables and SQL analyses (04_SQL/)
        └──→ Product, operations, forecasting, inactivity-risk,
             and anomaly experiments (06_ML/)
                         ↓
           Tables, charts, and prediction CSVs
                         ↓
             Power BI report and interpretation
```

The Python, SQL, and Power BI components serve different purposes: Python prepares and investigates the data, SQL makes relational queries and reusable views possible, and Power BI presents selected metrics in an interactive format.

## 8. Setup and prerequisites

### Step 1 — Install Python packages

Install the packages listed in [Tools and technologies](#5-tools-and-technologies). Then start Jupyter from the project environment:

```bash
jupyter notebook
```

Open notebooks from their numbered folders. Run them in the recommended order in the next section.

### Step 2 — Set up MySQL if you want to run SQL

Install/start MySQL and open `04_SQL/00_database_setup.sql` in MySQL Workbench or a compatible SQL client. Review the file before running it. It creates the `smart_demand_intelligence` database and tables, then contains `LOAD DATA LOCAL INFILE` commands that import cleaned CSV files.

The SQL setup script includes a machine-specific CSV path. Change each path to the actual location of your `02_Clean_Data/` folder before executing. MySQL client/server settings may need to allow local file imports; enable this only if it is permitted in your environment. Run the setup against a local development database, not a production database.

### Step 3 — Open Power BI

Open `05_Power_BI/Smart_Demand_Intelligence.pbix` with Power BI Desktop. If it connects to MySQL, check the data source settings and update the server/database credentials for your own machine. If a refresh fails, inspect the connection and data source configuration before changing the report.

## 9. Run the Python notebooks

Run the notebooks in this order where possible:

1. **`03_Python/01_data_loading.ipynb`** — loads the nine raw files, displays shapes, column names, and sample records. It is primarily an inspection notebook.
2. **`03_Python/02_data_cleaning.ipynb`** — standardizes column names, checks/removes duplicate rows, converts relevant date fields, handles selected missing values, and writes cleaned CSV files to `02_Clean_Data/`.
3. **`03_Python/03_EDA.ipynb`** — summarizes the cleaned data and produces exploratory charts and KPI/missing-value summaries in `09_Outputs/`.
4. **`03_Python/04_feature_engineering.ipynb`** — builds order-level and customer-level features used to explore purchasing behavior and customer value.
5. **`06_ML/05_product_location_intelligence.ipynb`** — examines category, seller, and geographic patterns.
6. **`06_ML/06_operations_intelligence.ipynb`** — creates order-level operational features and delivery/SLA summaries.
7. **`06_ML/07_demand_forecasting.ipynb`** — creates daily order counts, evaluates a seasonal-naive baseline against a Random Forest model, and produces a 30-day forecast.
8. **`06_ML/08_customer_churn.ipynb`** — builds an exploratory inactivity-risk label and classification experiment.
9. **`06_ML/09_anomaly_detection.ipynb`** — applies rule-based IQR flags and Isolation Forest to identify unusual order-level patterns.

Some ML notebooks rely on the cleaned CSVs, so run data loading/cleaning first if regenerating the project from raw files. Run notebooks from top to bottom and inspect the printed row counts and saved-file messages. Existing notebook outputs are examples of a prior run and may not match if you change data, paths, packages, or code.

## 10. Run the SQL analysis

The SQL files are organized by purpose:

- `00_database_setup.sql`: create the database/tables and import cleaned CSVs.
- `01_basic_analysis.sql`: broad order, revenue, and general performance queries.
- `02_customer_analysis.sql`: customer behavior and segmentation queries.
- `03_product_analysis.sql`: category and product performance queries.
- `04_delivery_analysis.sql`: delivery duration and delivery status/SLA analysis.
- `05_Business_kpis.sql`: consolidated business KPI calculations.
- `06_powerbi_views.sql`: reusable SQL views intended to support Power BI reporting.

Recommended process:

1. Review and update the local file paths in `00_database_setup.sql`.
2. Create/load the database using the setup script.
3. Verify that each table has records before running analysis queries.
4. Run the remaining scripts in order, checking their results.
5. If Power BI uses MySQL views, confirm the views exist and that Power BI can connect to the same database.

Be careful when combining order-level and item-level data. An order can contain multiple items, so joining orders directly to order items duplicates order-level values across item rows. Aggregate item data to order level before calculating order-level averages or counts.

## 11. Explore the Power BI report

The PBIX file is intended to contain six pages:

1. **Executive Overview** — high-level KPIs and business summary.
2. **Demand Intelligence** — demand patterns over time and forecast outputs.
3. **Customer Intelligence** — customer behavior, segments, and inactivity-risk summaries.
4. **Product Intelligence** — category, product, and seller performance.
5. **Operations Intelligence** — delivery and operational metrics.
6. **AI / ML Intelligence** — model comparisons and anomaly/risk outputs.

Page titles describe the intended focus; exact visuals, filters, and available data depend on the PBIX version and whether its data sources refresh successfully. Before presenting, open the file in Power BI Desktop, refresh the data if possible, and check that each page renders correctly. Do not assume that a saved PBIX is connected to your current MySQL instance until you test it.

## 12. Machine-learning and intelligence modules

### 12.1 Demand forecasting

The target is the number of orders purchased per day. The notebook creates calendar features and lag/rolling-history features, then compares a seasonal-naive baseline (using the same weekday from the previous week) with a Random Forest regressor. It also generates an iterative 30-day forecast.

This is a useful learning experiment, but its forecasts should be treated as indicative rather than operational commitments. Error can be large when daily order counts vary considerably. The model should be re-evaluated with time-based validation and compared with additional baselines before real-world use.

### 12.2 Customer inactivity risk

The customer notebook creates an inactivity target based on a historical recency threshold (180 days in the current analysis) and trains a classifier to distinguish the target classes. This is a **proxy for inactivity risk**, not verified churn: the dataset does not provide a confirmed business definition of churn or a future customer outcome label. Performance is modest in the current experiment, so risk groups should be used for exploration, not for automated customer decisions.

### 12.3 Anomaly detection

The anomaly notebook uses two approaches:

- **IQR rule-based detection:** flags values outside interquartile-range thresholds for selected numerical features.
- **Isolation Forest:** an unsupervised model that identifies records that differ from the overall feature distribution.

An anomaly flag means a record deserves review; it does not prove fraud, an error, or misconduct. Investigate flagged orders with business context before drawing conclusions.

### 12.4 Product/location and operations intelligence

These notebooks aggregate item sales by category and geography and calculate operational measures from order timestamps, sellers, customers, and order items. Delivery metrics must use delivered orders consistently. In particular, a delivery timestamp alone is not a reliable definition of a delivered order because the dataset may contain inconsistent timestamps for non-delivered statuses.

## 13. Outputs and how to interpret them

### `09_Outputs/charts/`

Contains PNG charts produced by the notebooks, including order status, monthly/daily demand, category revenue, payment methods, delivery duration, review scores, state-level orders, customer segments, forecast evaluation, feature importance, and anomaly classifications.

### `09_Outputs/tables/`

Contains CSV tables for EDA summaries, cleaning reports, category and state performance, customer KPIs and segments, delivery/SLA analysis, operational summaries, forecast evaluation, and anomaly counts. These tables are useful for validating calculations or feeding reporting tools.

### `09_Outputs/predictions/`

Contains model output files such as:

- `30_day_demand_forecast.csv`
- `customer_inactivity_risk_predictions.csv`
- `customer_risk_model_performance.csv`
- `order_anomaly_predictions.csv`

Always check the date range, row count, and generation time when using saved outputs. If you modify a notebook, rerun it and replace the associated outputs so that charts, CSVs, and Power BI are based on the same version of the data.

## 14. KPI definitions

Definitions must be consistent across Python, SQL, and Power BI. The following are recommended interpretations; check the exact query or measure before comparing numbers across tools.

| KPI | Recommended definition | Important caution |
|---|---|---|
| Order count | Count of distinct `order_id` values | Do not count item rows as orders. |
| Item revenue | Sum of `order_items.price` | This excludes freight. |
| Freight | Sum of `order_items.freight_value` | Keep separate from item revenue when possible. |
| Order value including freight | Order-level item revenue plus order-level freight | Aggregate items to each order before calculating order-level statistics. |
| Average order value (AOV) | Total item revenue divided by the number of eligible distinct orders | State which order statuses are included. Do not average item rows and call it AOV. |
| Repeat-customer rate | Customers with more than one order divided by eligible unique customers | Use `customer_unique_id` to represent a customer across multiple order-specific customer IDs. State the denominator and time window. |
| Delivery duration | Delivered-customer timestamp minus purchase timestamp | Calculate only for orders with `order_status = 'delivered'` and valid timestamps. |
| SLA delay | Actual delivered calendar date later than estimated delivery calendar date | Compare dates consistently and exclude non-delivered orders from delivered-order SLA percentages. |
| Review score | Average of valid review scores | Joining reviews to multiple item rows can duplicate reviews; aggregate reviews independently or deduplicate by review/order as appropriate. |
| Forecast error | MAE, RMSE, and/or MAPE on a held-out time period | MAPE can become unstable when actual values are zero or small. |
| Inactivity risk | Model probability for the notebook's inactivity proxy label | Not the same as confirmed customer churn. |
| Anomaly rate | Number of flagged records divided by the number of eligible records scored | State whether this is IQR, Isolation Forest, or a combined rule. |

## 15. Current findings

The current project outputs have previously reported the following exploratory results. Treat these as **provisional until the affected notebooks and SQL/Power BI measures have been rerun and reconciled**:

- The Random Forest demand model performed better than the seasonal-naive baseline on the saved evaluation period, but forecast errors remained substantial.
- The 30-day forecast output previously summed to about 3,214 predicted orders, averaging about 107 per day. This is a model output, not actual future demand.
- The customer inactivity experiment previously achieved a ROC-AUC around 0.61, indicating limited ability to separate the two proxy-label classes.
- The anomaly analysis previously flagged roughly 20.8% of eligible orders with the IQR rule and about 2% with Isolation Forest. The two methods use different criteria, so their percentages should not be interpreted as interchangeable.
- Earlier analysis identified `health_beauty` as a leading category by item revenue and `bed_bath_table` as a leading category by units in the saved category summaries. Verify against the latest generated table before using these claims in a final report.

**Delivery KPI validation is still pending.** Some canceled orders in this dataset have delivery timestamps. The operations notebook should filter delivery metrics using both `order_status == 'delivered'` and valid delivery timestamps, and the SLA classification should label non-delivered orders separately. Re-run the operations notebook and refresh any dependent SQL/Power BI results before treating delivery metrics as final.

## 16. Limitations and validation notes

- The data is historical and specific to the Olist marketplace in Brazil; results do not automatically generalize to other countries or businesses.
- The notebook paths and SQL import paths are machine-specific and need configuration on another computer.
- Demand forecasting is a basic experiment and should be improved with more robust time-series validation, holiday/event features, and additional baselines.

  https://github.com/vishalkumar54singh/Smart_E-Commerce_Intelligence_System/blob/main/05_Power_BI/Smart_Demand_Intelligence.pbix
- The inactivity label is a proxy based on historical recency, not a confirmed churn label. Model performance is modest.
- Anomaly models identify unusual patterns, not confirmed fraud.
- Delivery calculations need the delivered-status filter described above before final reporting.
- SQL, Python, and Power BI metrics can disagree if filters, join levels, definitions, or refresh states differ. Reconcile important KPIs before submission.
- The PBIX needs to be opened and refreshed in the intended environment to validate data connections and visual rendering.
- The `07_Reports/` and `08_Presentation/` folders are reserved for final deliverables and may be empty at this stage.

## 17. Troubleshooting

**`FileNotFoundError` while loading CSVs**

- Check the project extraction location.
- Update `Data_Path`, `Raw_Data_Path`, `Clean_Data_Path`, `Table_Path`, `Chart_Path`, and `Prediction_Path` variables as applicable.
- Confirm the expected CSV exists in the referenced folder.

**Cleaned CSVs are missing**

- Run `03_Python/02_data_cleaning.ipynb` from top to bottom.
- Check that its output path points to `02_Clean_Data/` and that the folder is writable.

**Charts or CSV outputs are not updating**

- Run the notebook cells that create and save those outputs.
- Check the output folder path and file modification time.
- Avoid mixing old CSVs with newly generated notebook outputs.

**MySQL `LOAD DATA LOCAL INFILE` fails**

- Verify the path in `00_database_setup.sql`.
- Check whether local file loading is permitted by both the client and server configuration.
- Ensure the CSV files exist and the SQL column order matches the CSV column order.
- Review MySQL error messages and permissions rather than enabling broad permissions unnecessarily.

**Power BI cannot refresh**

- Check the selected data source and server/database names.
- Confirm MySQL is running and credentials are correct.
- Verify the SQL views/tables exist and the user has permission to read them.
- Reopen the report and refresh after correcting the connection settings.

**Python notebook reports different values than saved tables**

- Check whether all cells were rerun after a code change.
- Confirm that output files were overwritten in the intended directory.
- Verify status filters, date ranges, distinct-count logic, and whether the calculation is order-level or item-level.

## 18. Author and project status

This repository is intended as a learning and portfolio project demonstrating a workflow across data cleaning, exploratory analysis, SQL, dashboards, and introductory machine learning.

**Current status:** Core analysis assets and the Power BI file are present. Final delivery metrics still need the status-filter correction described above, and Power BI refresh should be checked in the target environment. The written report and presentation are planned follow-up deliverables.
