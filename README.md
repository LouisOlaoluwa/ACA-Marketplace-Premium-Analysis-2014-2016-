# ACA Health Insurance Marketplace Premium Analysis (2014–2016)

An end-to-end SQL and Python data analysis project examining 12+ million health insurance marketplace rate records from the Centers for Medicare & Medicaid Services (CMS).

## 📌 Project Overview

This project analyzes premium rate structures across the 2014–2016 ACA Health Insurance Marketplace and evaluates data quality, referential integrity, and relationships between multiple marketplace tables.

The project combines SQLite, SQL, and Python to investigate premium distributions, identify anomalous values, reconcile inconsistent identifiers, and validate relationships across tables including `Rate`, `PlanAttributes`, `Network`, `BenefitsCostSharing`, and `ServiceArea`.

## 🛠️ Tech Stack & Tools

* **Language:** Python 3.x
* **Database:** SQLite
* **Data Processing:** Pandas, NumPy
* **Visualization:** Seaborn, Matplotlib
* **Querying:** SQL

## 🔑 Key Engineering & Data Quality Insights

* **Primary Key Reconciliation:** Identified differences in identifier formats between `Rate` and `PlanAttributes`, including base Plan IDs and variant suffixes, and developed join logic to reconcile the records.
* **Data Anomaly Detection:** Identified extreme premium values, including `9999.99`, `9999`, `99999`, `999999` and excluded these placeholder/anomalous values (along with rates `<10`) from premium statistical analysis.
* **Referential Integrity:** Audited relationships between marketplace tables and identified issuer-mapping inconsistencies, including issuers present in `Rate` but absent from `Network`.
* **Multi-Year Data Validation:** Compared records across 2014–2016 to identify inconsistencies, duplicates, and year-specific data-quality issues.
* **Premium Distribution Analysis:** Examined premium distributions using descriptive statistics, percentiles, IQR, skewness, and visualizations to understand the structure and variability of marketplace rates.



## 📈 Key Findings

* Premiums increase consistently from Bronze to Platinum, with the largest jump occurring between Bronze and Silver.
* Platinum plans show the widest premium variability (IQR $365.10) compared to Bronze ($222.68), indicating greater pricing dispersion for richer coverage.
* Premiums vary 2–3x across states, with the highest-average states (e.g. Alaska) far exceeding the lowest.
* Catastrophic plans had the lowest median premium: $239.13, reflecting their distinct coverage structure.
* Premiums were right-skewed: Bronze (4.33) and Catastrophic (9.10) showed the strongest skewness, making the median more representative than the mean.
* Silver had the most records among the analyzed metal tiers.
* PPO and HMO dominated: They represented 42.76% and 39.75% of records respectively, together accounting for approximately 82.5%.
* State-level premiums varied substantially: Alaska had the highest average premium at approximately $673.12/month, about 3.7× the lowest-average state.
* State-level variability differed considerably: Missouri and Virginia had the highest coefficients of variation at approximately 128%, while Alaska had high premiums but relatively low variation.
* Tobacco-rated premiums were higher: Tobacco-rated plans showed an estimated 18.9% average surcharge compared with non-tobacco rates.
* Premiums increased with age: Rates generally increased with age, with growth becoming more pronounced around ages 45–50.
* Premiums increased by metal tier: Median premiums rose from $320.65 (Bronze) to $393.78 (Silver), $463.95 (Gold), and $527.08 (Platinum).

  
## 📊 How to Run

1. Clone this repository:

```bash
[git clone https://github.com/LouisOlaoluwa/ACA-Marketplace-Premium-Analysis-2014-2016.git
cd ACA-Marketplace-Premium-Analysis-2014-2016](https://github.com/LouisOlaoluwa/ACA-Marketplace-Premium-Analysis-2014-2016-)
```

2. Install the required Python packages:

```bash
pip install pandas numpy matplotlib seaborn
```

3. Download the CMS Health Insurance Marketplace dataset from [kaggle.com](https://www.kaggle.com/datasets/hhs/health-insurance-marketplace) and place the SQLite file in the project root.

4. Open and run `ACA-Marketplace-Premium-Analysis-2014-2016.ipynb` in Jupyter Notebook.

## 🎯 Project Objectives

* Analyze ACA marketplace premium rates across multiple years.
* Identify and investigate data-quality anomalies.
* Reconcile inconsistent identifiers across related tables.
* Validate cross-table relationships using SQL.
* Use Python for statistical analysis and visualization.
* Demonstrate practical data-cleaning and database-analysis workflows.

## ⚠️ Limitations

* The analysis is based on ACA Marketplace filings from 2014–2016 and may not fully reflect the current health insurance market.
* Premiums do not account for government subsidies or tax credits that reduce the amount many consumers actually pay.
* IndividualRate represents the listed monthly premium rather than the actual out-of-pocket premium paid by enrollees.
* Plan popularity and enrollment counts were unavailable, preventing analysis of which plans consumers selected most frequently.
* Medical claims and healthcare utilization data were not included, limiting the ability to relate premiums to actual healthcare costs or outcomes.
* Insurer names were represented only by IssuerId, preventing meaningful insurer-level comparisons and reducing the interpretability of company specific analyses.
