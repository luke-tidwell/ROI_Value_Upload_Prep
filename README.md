# ROI Value Upload Prep (Vena)

**Purpose:**  
This SQL script prepares **ROI forecast** and **actual values** for capital projects into a standardized format required by **Vena**. It reshapes raw ROI data and aggregates actual GL values into year-based groupings (“1st Year,” “2nd Year,” etc.), producing an upload-ready dataset.

---

## 🔍 What the Script Does
1. **Forecasts (ROI_Values):**
   - Transforms ROI forecast data from wide format into long format (`Project_ID`, `Year`, `GL_Account`, `Value`).
   - Maps revenue, costs, wages, utilities, depreciation, interest, and taxes to GL accounts.
   - Assigns each row to a timeline year (`1st Year`, `2nd Year`, `3rd Year`, etc.).
   - Inserts **Gross Book Value (GBV)** for each project.

2. **Actuals (Journal Entries):**
   - Pulls GL journal entries for retail projects across key accounts.
   - Defines each project’s **first full fiscal period** after opening.
   - Groups fiscal periods into years (13-period years).
   - Aggregates GL values by `Project_ID`, `GL_Account`, and year.
   - Labels scenario as `Actuals`.

3. **Combine Forecast & Actuals:**
   - Produces one unified dataset with columns:
     - `_PROJECT_FACT_ID`
     - `_TIMELINE_YEAR` (1st Year, 2nd Year, etc.)
     - `_GL_ACCOUNT`
     - `_SCENARIO` (Forecast or Actuals)
     - `_VALUE`

---

## 📂 File
- `ROI_Value_Upload_Prep.sql` — complete script for preparing ROI values and actuals for Vena.

---

## ✅ Example Output (simplified)

| _PROJECT_FACT_ID | _TIMELINE_YEAR | _GL_ACCOUNT | _SCENARIO | _VALUE   |
|------------------|----------------|-------------|-----------|----------|
| 100234           | 1st Year       | 4200-01     | Forecast  | -250000  |
| 100234           | 1st Year       | 6010-01     | Forecast  | 120000   |
| 100234           | 1st Year       | 4200-01     | Actuals   | -245000  |
| 100234           | 1st Year       | 6010-01     | Actuals   | 118500   |

---

## 🛠️ Usage
1. Ensure you have access to:
   - `ROI_Values`
   - `Capital_Project_Fact`
   - `Journal_Entries`
   - `Organization`
   - `Fiscal_Calendar`
   - `v_Financial_Terms` (GL definitions)

2. Open `ROI_Value_Upload_Prep.sql` in **SQL Server Management Studio (SSMS)**.

3. Run the script:
   - Temporary tables (`#ROI`, `#VENA_UPLOAD_ROI`, `#ACTUALS`, etc.) are created.
   - Forecasts and actuals are processed separately.
   - Final `SELECT` unions both datasets.

4. Export the result set to CSV and upload into Vena.

---

## ⚙️ Environment / Requirements
- Microsoft SQL Server
- SSMS (or similar query tool)
- Database access with read permissions on ROI, Capital Projects, GL, and Calendar tables.

---

## 📝 Notes for Reviewers
- Script includes both **forecast** and **actuals** logic for consistency in upload format.
- Period grouping for actuals is based on **first full fiscal period** after project opening.
- Designed for repeatable execution — rerunning will always produce current values.

---

## 📄 License
MIT
