# Data Pipeline Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DATA COLLECTION PHASE                              │
└─────────────────────────────────────────────────────────────────────────────┘

SOURCE 1: KAGGLE NSE DATA                    SOURCE 2: MACROECONOMIC DATA
         ↓                                            ↓
  19 CSV files                            Hard-coded historical rates
  (2008-2025)                             (CBR, T-Bill, Inflation)
         │
         ├─ Standardize columns
         ├─ Filter for NASI
         ├─ Convert DATE to datetime
         └─ Sort by date
              │
              ↓
        ┌─────────────────┐
        │   nasi_cbr      │  (19,000+ rows × 15 cols)
        │   (Combined)    │
        └────────┬────────┘
                 │
                 ↓
        ┌─────────────────────────┐
        │     nasi_data           │  (4,211 rows - filtered for NASI only)
        │  (Saved to CSV)         │
        └────────┬────────────────┘
                 │
                 ├─ (ALL TRADING DAYS)
                 │
  ┌──────────────┼──────────────────────────────────────────┐
  │              │                                          │
  ↓              ↓                                          ↓
CBR_df       TBill_df                                 Inflation_df
40 rows      35 rows                                   35 rows


┌─────────────────────────────────────────────────────────────────────────────┐
│                    DATA MERGING PHASE (merge_asof)                         │
│                   Carries forward last known rates                          │
└─────────────────────────────────────────────────────────────────────────────┘

nasi_data (4,211 daily records)
    ↓
merge_asof with CBR_df (backward)
    ↓
merge_asof with TBill_df (backward)
    ↓
merge_asof with Inflation_df (backward)
    ↓
    ┌──────────────────────────────────┐
    │      final_nasi                  │
    │  (4,211 rows × 18 columns)      │
    │  - NASI data + 3 macro vars     │
    │  - All trading days have        │
    │    latest CBR/TBill/Inflation   │
    └────────┬─────────────────────────┘
             │
             ↓ (Saved to CSV)


┌─────────────────────────────────────────────────────────────────────────────┐
│                    DATA CLEANING PHASE                                     │
└─────────────────────────────────────────────────────────────────────────────┘

final_nasi (4,211 × 18 columns)
    │
    ├─ Consolidate 3 Adjusted Price Columns
    │  └─ Adjust → Adjusted → Adjusted price → Day price (fallback)
    │  └─ Creates: Adjusted_Close
    │
    ├─ Keep Essential Columns Only (9 total):
    │  ✓ Date
    │  ✓ Code
    │  ✓ Day price
    │  ✓ Adjusted_Close (NEW)
    │  ✓ Day low
    │  ✓ Day high
    │  ✓ 12m low
    │  ✓ 12m high
    │  ✓ CBR_Rate
    │
    └─ Drop Unnecessary Columns (9 removed):
       × Name, Previous, Change, Change%, Volume
       × Adjust, Adjusted, Adjusted price

    ↓
    ┌──────────────────────────────────┐
    │       nasi_data                  │
    │  (4,211 rows × 9 columns)       │
    │  CLEAN & READY FOR ANALYSIS     │
    └──────────────────────────────────┘
             │
             ↓ (Saved to CSV)
    nasi_cleaned.csv


┌─────────────────────────────────────────────────────────────────────────────┐
│                          DATA READY FOR ANALYSIS                           │
│                     All 3 Primary CSVs Completed                           │
└─────────────────────────────────────────────────────────────────────────────┘

CSV 1: nasi_2008_2025.csv
       └─ NASI index data, 2008-2025

CSV 2: nasi_with_macro_final.csv
       └─ NASI + CBR + T-Bill + Inflation (422 KB)

CSV 3: nasi_cleaned.csv (RECOMMENDED FOR ANALYSIS)
       └─ NASI + Adjusted_Close + CBR only (9 essential columns)


NEXT STEPS:
═══════════════
1. Load nasi_cleaned.csv
2. Exploratory Data Analysis (visualizations, correlations)
3. Feature Engineering (returns, lags, moving averages)
4. Statistical Analysis & Modeling
5. Generate insights & visualizations
```

---

## Key Insight: What merge_asof Does

When you have trading days that don't align with CBR announcement dates:

```
NASI Trading Days:              CBR Announcement Dates:
2025-11-06                      2025-02-05  (10.75%)
2025-11-07
2025-11-08      ←───merge_asof──→ Each trading day gets
2025-11-09                       the LAST known CBR rate
2025-12-02
...
```

So every trading day has the most recent CBR rate available!

