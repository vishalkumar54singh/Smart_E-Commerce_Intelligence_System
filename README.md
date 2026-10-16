# Smart E-Commerce Demand & Operations Intelligence System

An end-to-end data analytics and business intelligence project built using the Brazilian Olist e-commerce dataset. This project combines **Python, SQL, Machine Learning, and Power BI** to analyze sales demand, customer behavior, product performance, and delivery operations.

## 📌 Project Overview

The project transforms raw e-commerce data into meaningful business insights through data cleaning, exploratory data analysis, SQL analytics, machine learning experiments, and interactive dashboards.

**Objectives:**

- Analyze order trends and sales performance.
- Understand customer purchasing behavior.
- Identify high-performing product categories and locations.
- Evaluate delivery performance and operational efficiency.
- Experiment with demand forecasting and anomaly detection.
- Present key insights through Power BI dashboards.

## 🛠️ Technologies Used

| Technology           | Purpose                                   |
| -------------------- | ----------------------------------------- |
| Python               | Data analysis and preprocessing           |
| Pandas & NumPy       | Data manipulation and feature engineering |
| Matplotlib & Seaborn | Data visualization                        |
| Scikit-learn         | Machine learning experiments              |
| MySQL                | Database management and SQL analytics     |
| Jupyter Notebook     | Interactive analysis                      |
| Power BI             | Business intelligence and dashboards      |

## 📊 Dataset

**Source:** [Brazilian E-Commerce Public Dataset by Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset contains information about orders, customers, products, sellers, payments, reviews, and deliveries from the Brazilian e-commerce marketplace.

## ✨ Key Features

- **Data Cleaning:** Prepare and standardize raw datasets for analysis.
- **Exploratory Data Analysis:** Discover trends, patterns, and relationships.
- **Customer Analytics:** Explore purchasing behavior and customer segments.
- **Product Intelligence:** Analyze category performance, sales, and seller activity.
- **Operations Analytics:** Examine delivery duration and estimated delivery performance.
- **Demand Forecasting:** Experiment with historical order data to estimate future demand.
- **Anomaly Detection:** Identify unusual order patterns for further investigation.
- **Power BI Dashboard:** Present business metrics and analytical insights visually.

## 📁 Project Structure

```text
Smart_E-Commerce_Demand_&_Operations_Intelligence_System/
├── 01_Raw_Data/
├── 02_Clean_Data/
├── 03_Python/
│   ├── 01_data_loading.ipynb
│   ├── 02_data_cleaning.ipynb
│   ├── 03_EDA.ipynb
│   └── 04_feature_engineering.ipynb
├── 04_SQL/
│   ├── 00_database_setup.sql
│   ├── 01_basic_analysis.sql
│   ├── 02_customer_analysis.sql
│   ├── 03_product_analysis.sql
│   ├── 04_delivery_analysis.sql
│   ├── 05_Business_kpis.sql
│   └── 06_powerbi_views.sql
├── 05_Power_BI/
│   └── Smart_Demand_Intelligence.pbix
├── 06_ML/
│   ├── 05_product_location_intelligence.ipynb
│   ├── 06_operations_intelligence.ipynb
│   ├── 07_demand_forecasting.ipynb
│   ├── 08_customer_churn.ipynb
│   └── 09_anomaly_detection.ipynb
├── 07_Reports/
├── 08_Presentation/
├── 09_Outputs/
└── README.md
```

## ⚙️ Getting Started

### Prerequisites

- Python 3
- Jupyter Notebook
- MySQL Server and MySQL Workbench (for SQL analysis)
- Power BI Desktop (for dashboard exploration)

### 1. Clone the repository

```bash
git clone https://github.com/vishalkumar54singh/Smart_E-Commerce_Intelligence_System.git
cd Smart_E-Commerce_Intelligence_System
```

### 2. Install Python dependencies

```bash
python -m venv .venv
```

Activate the environment on Windows:

```bash
.venv\Scripts\activate
```

Install the required packages:

```bash
python -m pip install pandas numpy matplotlib seaborn scikit-learn jupyter ipykernel
```

### 3. Run the notebooks

Start Jupyter Notebook:

```bash
jupyter notebook
```

Run the notebooks in `03_Python/` in numerical order, followed by the relevant notebooks in `06_ML/`.

### 4. Run the SQL analysis

1. Open the SQL scripts in MySQL Workbench.
2. Review the database setup script and update CSV file paths.
3. Import the required data into MySQL.
4. Execute the analysis scripts.

### 5. Open the Power BI report

Open `05_Power_BI/Smart_Demand_Intelligence.pbix` in Power BI Desktop. Configure the data source and refresh the report if required.

## 📈 Outputs

The `09_Outputs/` directory organizes generated analytical results:

- `charts/` — visualizations and analytical charts.
- `tables/` — summary tables and CSV reports.
- `predictions/` — demand forecasts, customer inactivity-risk predictions, and anomaly detection results.

## ⚠️ Limitations

- The analysis is based on historical Brazilian e-commerce data and may not generalize to other markets.
- Demand forecasts are exploratory estimates, not production forecasting services.
- Customer inactivity is a proxy label, not confirmed customer churn.
- Anomaly detection identifies unusual patterns, not confirmed fraud.
- Delivery metrics and dashboard data connections should be validated before final reporting.

## 🚀 Project Status

The repository brings together data analysis, SQL, machine learning experiments, and Power BI reporting. Further validation and refinement of analytical results and dashboard connections remain part of the project workflow.

---

<<<<<<< HEAD
Recommended process:

1. Review and update the local file paths in `00_database_setup.sql`.
2. Create/load the database using the setup script.
3. Verify that each table has records before running analysis queries.
4. Run the remaining scripts in order, checking their results.
5. If Power BI uses MySQL views, confirm the views exist and that Power BI can connect to the same database.

Be careful when combining order-level and item-level data. An order can contain multiple items, so joining orders directly to order items duplicates order-level values across item rows. Aggregate item data to order level before calculating order-level averages or counts.

## 11. Explore the Power BI report

The PBIX file is intended to contain six pages:

1. **Executive Overview** — high-level KPIs and business summary. ![Dashboard Preview](https://github.com/vishalkumar54singh/Smart_E-Commerce_Intelligence_System/blob/main/05_Power_BI/01.png)
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
**Dataset:** [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
