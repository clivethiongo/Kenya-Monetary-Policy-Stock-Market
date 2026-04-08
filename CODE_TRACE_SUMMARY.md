# Kenya Monetary Policy & Stock Market Analysis - Code Trace Summary

## Project Overview
Analyzing the relationship between Kenya's Central Bank Rate (CBR), Treasury Bill rates, Inflation, and the NSE All-Share Index (NASI).

---

## 📊 Data Pipeline Completed

### **Cell 1: Environment Setup**
- Python executable: `c:\Users\thion\.conda\envs\learn-env\python.exe`
- Libraries imported: pandas, numpy, matplotlib, seaborn

---

### **Cell 2: Data Collection - NSE NASI Data**
**Source:** Kaggle dataset via `kagglehub`
**Dataset:** "macmini62/nairobi-securities-exchangense-stocks-data"

**What it does:**
1. Downloads 19 NSE CSV files from Kaggle
2. Standardizes column names (uppercase)
3. Renames 'TICKER' column to 'CODE' for consistency
4. Concatenates all files into single dataframe: **`nasi_cbr`**
5. Filters for NASI (NSE All-Share Index)
6. Converts DATE column to datetime format
7. Sorts by date
8. Saves to: `notebooks/data/raw/nasi_2008_2025.csv`

**Output:**
- Dataframe: **`nasi_data`** (4,211 rows)
- Date range: 2008-01-04 to 2025-12-09

---

### **Cell 3: Merge with Macroeconomic Data**
**What it does:**

#### **3a. CBR (Central Bank Rate) Data**
- Hard-coded historical CBR rates (2007-2026)
- 40 data points
- Created dataframe: **`cbr_df`**

#### **3b. T-Bill 91-Day Rate**
- 91-day Treasury Bill rates (monthly)
- 35 data points from 2008-2025
- Created dataframe: **`tbill_df`**

#### **3c. Kenya Inflation Rate**
- Year-on-year CPI inflation rates (monthly)
- 35 data points from 2008-2025
- Created dataframe: **`inflation_df`**

#### **3d. Data Merging with merge_asof**
```python
final_nasi = pd.merge_asof(nasi_df,   cbr_df,       on='Date', direction='backward')
final_nasi = pd.merge_asof(final_nasi, tbill_df,     on='Date', direction='backward')
final_nasi = pd.merge_asof(final_nasi, inflation_df, on='Date', direction='backward')
```
- **Direction='backward'**: Carries forward the last known value to each trading day
- Saved to: `notebooks/data/processed/nasi_with_macro_final.csv`

**Final Columns in `final_nasi`:**
- Date
- Code
- Name
- 12m low, 12m high
- Day low, Day high
- Day price
- Previous, Change, Change%
- Volume
- Adjust, Adjusted, Adjusted price (need consolidation)
- CBR_Rate ✅
- TBill_91D ✅
- Inflation_Rate ✅

---

### **Cell 4: Data Cleaning & Consolidation**

**Objective:** Clean up adjusted price columns and keep only essential columns for analysis

**What it does:**

1. **Consolidate 3 Adjusted Price Columns → 1**
   - Priority order: `Adjust` → `Adjusted` → `Adjusted price`
   - Fallback to `Day price` if no adjusted price available
   - Creates: **`Adjusted_Close`** column

2. **Drop Unnecessary Columns**
   - Removed columns: Name, Previous, Change, Change%, Volume, Adjust, Adjusted, Adjusted price
   - Kept columns (9 total):
     - Date
     - Code
     - Day price
     - Adjusted_Close ✅ (NEW)
     - Day low
     - Day high
     - 12m low
     - 12m high
     - CBR_Rate

3. **Data Quality Check**
   - Info about data types
   - Missing values count
   - First 5 rows preview

**Output:**
- Clean dataframe: **`nasi_data`** (4,211 rows × 9 columns)
- Saved to: `notebooks/data/processed/nasi_cleaned.csv`

---

## 📁 Data Files Created

| File Name | Location | Size | Rows |
|-----------|----------|------|------|
| nasi_2008_2025.csv | data/raw/ | - | 4,211 |
| nasi_with_macro_final.csv | data/processed/ | 422 KB | 4,211 |
| nasi_cleaned.csv | data/processed/ | - | 4,211 |

---

## 🔄 Key Dataframes

| Name | Rows | Columns | Use |
|------|------|---------|-----|
| **nasi_cbr** | 19,000+ | 15 | Combined NSE data (intermediate) |
| **nasi_data** | 4,211 | 9 | Cleaned NASI data (FINAL) ✅ |
| **final_nasi** | 4,211 | 18 | NASI + macro variables (FINAL) ✅ |
| **cbr_df** | 40 | 2 | CBR rates |
| **tbill_df** | 35 | 2 | T-Bill rates |
| **inflation_df** | 35 | 2 | Inflation rates |

---

## ✅ Next Steps for Analysis

1. **Exploratory Data Analysis (EDA)**
   - Visualize NASI vs CBR trends
   - Check correlations
   - Identify patterns and seasonality

2. **Feature Engineering**
   - Calculate returns and percentage changes
   - Create lag variables
   - Add moving averages

3. **Statistical Analysis**
   - Correlation analysis
   - Time series decomposition
   - Stationarity tests

4. **Modeling**
   - Regression analysis (CBR impact on NASI)
   - Time series forecasting
   - Hypothesis testing

---

## 📝 Issues Encountered & Fixed

| Issue | Error | Solution |
|-------|-------|----------|
| Yahoo Finance ticker not available | HTTP 404 | Switched to Kaggle dataset |
| Date format mismatch | KeyError: 'Date' | Used `format='mixed', dayfirst=True` |
| Missing directory | FileNotFoundError | Added `os.makedirs(..., exist_ok=True)` |
| Multiple adjusted price columns | Inconsistent data | Consolidated into single `Adjusted_Close` |
| Duplicate module imports | - | Used `%reset -f` to clear variables |

---

## 🎯 Current Status
✅ **Data Collection**: COMPLETE
✅ **Data Merging**: COMPLETE
✅ **Data Cleaning**: COMPLETE
⏳ **Next Phase**: Exploratory Data Analysis

All work saved to git repository. Ready for analysis phase!
