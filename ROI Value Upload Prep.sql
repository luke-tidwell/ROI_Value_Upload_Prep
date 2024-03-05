
---- THIS SECTION FOR FORECAST VALUES ----

DROP TABLE IF EXISTS #ROI, #VENA_UPLOAD_ROI, --Forecast Tables
					 #ROI_LIST, #ACTUALS, #VENA_UPLOAD_ACTUALS, #OPENING_DEF,#PERIODS, #RAW_ACTUALS --Actuals Tables

SELECT * INTO #ROI FROM ROI_Values


-- DEFINE COLUMNS FOR UPLOAD
SELECT
pf.[PROJECT_ID] AS [_PROJECT_FACT_ID],
CASE
	WHEN DENSE_RANK() OVER (PARTITION BY pf.[PROJECT_ID] ORDER BY roi.[YEAR])= 1 THEN '1st Year'
	WHEN DENSE_RANK() OVER (PARTITION BY pf.[PROJECT_ID] ORDER BY roi.[YEAR])= 2 THEN '2nd Year'
	WHEN DENSE_RANK() OVER (PARTITION BY pf.[PROJECT_ID] ORDER BY roi.[YEAR])= 3 THEN '3rd Year'
	ELSE  CAST(DENSE_RANK() OVER (PARTITION BY pf.[PROJECT_ID] ORDER BY roi.[YEAR]) AS NVARCHAR(MAX)) + 'th Year'
	END AS [_TIMELINE_YEAR],
roi.[COLUMN_NAME] AS [_GL_ACCOUNT],
roi.[SCENARIO] AS [_SCENARIO],
SUM([COLUMN_VALUE]) AS [_VALUE]
INTO #VENA_UPLOAD_ROI
FROM 

-- BRING IN ROI VALUES
(SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('9010-04' AS NVARCHAR(MAX)) AS column_name, [Diesel_Gallons] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('9010-01' AS NVARCHAR(MAX)) AS column_name, [Unleaded_Gallons] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('9010-50' AS NVARCHAR(MAX)) AS column_name, [DEF_Gallons] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('9010-11' AS NVARCHAR(MAX)) AS column_name, [CLR_Gallons] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('4200-01' AS NVARCHAR(MAX)) AS column_name, -[Fuel_Gross] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('5200-01' AS NVARCHAR(MAX)) AS column_name, ([Fuel_Gross] - [Fuel_GP]) AS column_value -- Fuel COGS --
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('4300-05' AS NVARCHAR(MAX)) AS column_name, -[Merch] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('4310-10' AS NVARCHAR(MAX)) AS column_name, -[Fresch] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('5300-05' AS NVARCHAR(MAX)) AS column_name, ([Merch] - [Merch_GP]) AS column_value -- Merch COGS --
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('5310-10' AS NVARCHAR(MAX)) AS column_name, ([Fresch] - [Fresch_GP]) AS column_value -- Food Service COGS --
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('6010-01' AS NVARCHAR(MAX)) AS column_name, [Wages] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('7030-01' AS NVARCHAR(MAX)) AS column_name, [Utilities] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('7040-01' AS NVARCHAR(MAX)) AS column_name, [Maintenance] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('7075-01' AS NVARCHAR(MAX)) AS column_name, [CC_Bank] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('7100-03' AS NVARCHAR(MAX)) AS column_name, [Lease_Exp] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('7500-01' AS NVARCHAR(MAX)) AS column_name, [Depreciation] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('7300-01' AS NVARCHAR(MAX)) AS column_name, [Operations] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('7100-01' AS NVARCHAR(MAX)) AS column_name, [Land_Lease] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('8000-00' AS NVARCHAR(MAX)) AS column_name, [Interest] AS column_value
	FROM #ROI 
	UNION ALL SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('8100-00' AS NVARCHAR(MAX)) AS column_name, [Income_Taxes] AS column_value
	FROM #ROI 
	) roi 
LEFT JOIN Capital_Project_Fact pf
	ON (roi.Project_Summary_Key = pf.PROJECT_SUMMARY_KEY)
	OR (roi.Project_Summary_Key <> pf.PROJECT_SUMMARY_KEY
		AND roi.Project_Summary_Key = pf.Real_Estate_Land_Code)
WHERE pf.[PROJECT_ID] IS NOT NULL
AND Scenario = 'Forecast'
GROUP BY  pf.[PROJECT_ID], roi.[YEAR], roi.[COLUMN_NAME], roi.[SCENARIO]

-- INSERT MAX GROSS BOOK VALUE FOR EACH PROJECT
INSERT INTO #VENA_UPLOAD_ROI
SELECT
pf.[PROJECT_ID] AS [_PROJECT_FACT_ID],
CASE
	WHEN DENSE_RANK() OVER (PARTITION BY pf.[PROJECT_ID] ORDER BY gbv.[YEAR])= 1 THEN '1st Year'
	WHEN DENSE_RANK() OVER (PARTITION BY pf.[PROJECT_ID] ORDER BY gbv.[YEAR])= 2 THEN '2nd Year'
	WHEN DENSE_RANK() OVER (PARTITION BY pf.[PROJECT_ID] ORDER BY gbv.[YEAR])= 3 THEN '3rd Year'
	ELSE  CAST(DENSE_RANK() OVER (PARTITION BY pf.[PROJECT_ID] ORDER BY gbv.[YEAR]) AS NVARCHAR(MAX)) + 'th Year'
	END AS [_TIMELINE_YEAR],
gbv.[COLUMN_NAME] AS [_GL_ACCOUNT],
gbv.[SCENARIO] AS [_SCENARIO],
MAX([COLUMN_VALUE]) AS [_VALUE]
--INTO #VENA_UPLOAD_ROI
FROM 
(
SELECT
	[PROJECT_SUMMARY_KEY],
	[YEAR],
	[SCENARIO],
	CAST('1590-00' AS NVARCHAR(MAX)) AS column_name, [GBV] AS column_value
	FROM ROI_Values
	) GBV
LEFT JOIN Capital_Project_Fact pf
	ON (gbv.Project_Summary_Key = pf.PROJECT_SUMMARY_KEY)
	OR (gbv.Project_Summary_Key <> pf.PROJECT_SUMMARY_KEY
		AND gbv.Project_Summary_Key = pf.Real_Estate_Land_Code)
WHERE pf.[PROJECT_ID] IS NOT NULL
AND Scenario = 'Forecast'
GROUP BY  pf.[PROJECT_ID], gbv.[YEAR], gbv.[COLUMN_NAME], gbv.[SCENARIO]


---- THIS SECTION FOR ACTUALS VALUES ----

-- Define list of projects with an associated ROI
SELECT DISTINCT Project_Summary_Key INTO #ROI_LIST FROM ROI_Values


-- Pull raw GL values for related accounts
SELECT
  gl_account_definitions.Full_GL_Account  AS [full_gl_account],
  organization.Site_ID  AS [site_id],
  calendar.Fiscal_Period_No  AS [fiscal_period_no],
  calendar.Fiscal_Year  AS [fiscal_year],
  COALESCE(SUM(journal_entries.JrnlEntry_Amount ), 0) AS [total_amount]
INTO #ACTUALS
FROM
journal_entries
INNER JOIN gl_accounts ON gl_accounts.GLAcct_Key = journal_entries.JrnlEntry_GLAcct_Key
INNER JOIN [v_Financial_Terms] AS gl_account_definitions ON gl_account_definitions.glacctmaj_key = gl_accounts.GLAcct_GLAcctMaj_Key
INNER JOIN  organization ON gl_accounts.GLAcct_Site_Acct = organization.Site_ID
LEFT JOIN [FISCAL_CALENDAR] AS calendar ON calendar.Date = (CONVERT(VARCHAR(10),journal_entries.JrnlEntry_Reference_Date ,120))
WHERE (gl_account_definitions.GL_Major_Account ) IN ('4200', '4300', '4310', '5200', '5300', '5310', '6010', '7030', '7040', '7075', '7100', '7300', '7500', '8000', '8100', '9010') AND (organization.business_type_adjusted ) = 'Retail'
GROUP BY
    gl_account_definitions.Full_GL_Account ,
    organization.Site_ID ,
    calendar.Fiscal_Period_No ,
    calendar.Fiscal_Year


--Specify which projects we want to look at and define it's first opening period
SELECT
	pf.PROJECT_ID,
	pf.SOFT_OPENING_DATE, 
	cal.FISCAL_PERIOD_NO,
	cal.FISCAL_DAY_OF_PERIOD,
	CASE
		WHEN (Fiscal_Period_No LIKE '%13') THEN (Fiscal_Period_No + 88) --Assuming first full period always after opening period.
		ELSE (Fiscal_Period_No + 1)
	END AS FIRST_FULL_PERIOD
INTO #OPENING_DEF
FROM Capital_Project_Fact pf
JOIN Calendar cal
	ON pf.SOFT_OPENING_DATE = cal.Date 
JOIN #ROI_LIST roi
	ON roi.Project_Summary_Key = pf.CAPITAL_PROJECT_KEY
WHERE pf.SOFT_OPENING_DATE IS NOT NULL
AND pf.SOFT_OPENING_DATE > '2018-12-31'
ORDER BY SOFT_OPENING_DATE DESC


--Create list of fiscal periods for the purpose of counting and grouping periods 
SELECT Fiscal_Period_No, ROW_NUMBER() OVER(ORDER BY FISCAL_PERIOD_NO) AS [INDEX]
INTO #PERIODS
FROM (SELECT DISTINCT FISCAL_PERIOD_NO AS FISCAL_PERIOD_NO FROM Calendar) AS SUB
ORDER BY Fiscal_Period_No


--Assign period_group to designate which year each period belongs to
SELECT
pf.[PROJECT_ID] AS [PROJECT_FACT_ID],
per.FISCAL_PERIOD_NO,
(ROW_NUMBER() OVER (PARTITION BY pf.[PROJECT_ID], AC.FULL_GL_ACCOUNT ORDER BY AC.FULL_GL_ACCOUNT, pf.[PROJECT_ID], PER.FISCAL_PERIOD_NO) - 1) / 13 + 1 AS period_group,
ac.FULL_GL_ACCOUNT,
ac.TOTAL_AMOUNT
INTO #Raw_Actuals
FROM Capital_Project_Fact pf
JOIN #OPENING_DEF op
	ON PF.PROJECT_ID = OP.PROJECT_ID
JOIN #PERIODS per
	ON PER.Fiscal_Period_No >= OP.FIRST_FULL_PERIOD 
	AND PER.Fiscal_Period_No <=
		(SELECT Fiscal_Period_No
		 FROM #PERIODS
		 WHERE [INDEX] = ((SELECT [INDEX] FROM #PERIODS WHERE FISCAL_PERIOD_NO = OP.FIRST_FULL_PERIOD) + (13*5))
		 )
JOIN #ACTUALS ac
	ON AC.site_id = PF.SITE_ID
	AND AC.fiscal_period_no = PER.FISCAL_PERIOD_NO
		
--Aggregate actual values in the format needed for Vena upload
SELECT
	[PROJECT_FACT_ID] AS [_PROJECT_FACT_ID],
	CASE
	WHEN period_group = 1 THEN '1st Year'
	WHEN period_group = 2 THEN '2nd Year'
	WHEN period_group = 3 THEN '3rd Year'
	ELSE  CAST(period_group AS NVARCHAR(MAX)) + 'th Year'
	END AS [_TIMELINE_YEAR],
    [FULL_GL_ACCOUNT] AS [_GL_ACCOUNT],
	'Actuals' AS [_SCENARIO],
    SUM(TOTAL_AMOUNT) AS [_VALUE]
INTO #VENA_UPLOAD_ACTUALS
FROM #Raw_Actuals
GROUP BY
    FULL_GL_ACCOUNT,
    [PROJECT_FACT_ID],
	period_group
ORDER BY
    [PROJECT_FACT_ID],
    period_group


SELECT * FROM #VENA_UPLOAD_ROI
	UNION ALL
SELECT * FROM #VENA_UPLOAD_ACTUALS
ORDER BY _PROJECT_FACT_ID, _TIMELINE_YEAR