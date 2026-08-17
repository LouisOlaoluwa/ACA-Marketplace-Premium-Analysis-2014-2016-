-- ============================================================================
-- ACA Health Insurance Marketplace Premium Analysis (2014-2016)
-- SQL queries extracted from the analysis notebook
-- Run against database.sqlite (tables: Rate, PlanAttributes, Network,
-- BenefitsCostSharing, ServiceArea, BusinessRules)
-- ============================================================================

-- Verify record counts (IssuerId / BusinessYear / StateCode) across all tables
SELECT
    'BusinessRules' AS Table_Name,
    COUNT(DISTINCT IssuerId) AS Unique_IssuerIds,
    COUNT(DISTINCT BusinessYear) AS Unique_BusinessYears,
    COUNT(DISTINCT StateCode) AS Unique_StateCodes
FROM BusinessRules

UNION ALL

SELECT
    'Network',
    COUNT(DISTINCT IssuerId),
    COUNT(DISTINCT BusinessYear),
    COUNT(DISTINCT StateCode)
FROM Network

UNION ALL

SELECT
    'PlanAttributes',
    COUNT(DISTINCT IssuerId),
    COUNT(DISTINCT BusinessYear),
    COUNT(DISTINCT StateCode)
FROM PlanAttributes

UNION ALL

SELECT
    'Rate',
    COUNT(DISTINCT IssuerId),
    COUNT(DISTINCT BusinessYear),
    COUNT(DISTINCT StateCode)
FROM Rate

UNION ALL

SELECT
    'ServiceArea',
    COUNT(DISTINCT IssuerId),
    COUNT(DISTINCT BusinessYear),
    COUNT(DISTINCT StateCode)
FROM ServiceArea;


-- Count Network records for two IssuerIds missing from Network but present in Rate
SELECT IssuerId,
       BusinessYear,
       StateCode,
       COUNT(*) AS NetworkRecords
FROM Network
WHERE IssuerId IN (38921, 45958)
GROUP BY IssuerId, BusinessYear, StateCode;


-- Count Rate records for the same two IssuerIds
SELECT IssuerId,
       BusinessYear,
       StateCode,
       COUNT(*) AS RateRecords
FROM Rate
WHERE IssuerId IN (38921, 45958)
GROUP BY IssuerId, BusinessYear, StateCode
ORDER BY IssuerId, BusinessYear, StateCode;


-- Check distinct PlanId/BusinessYear/IssuerId combinations in PlanAttributes
SELECT PlanId,BusinessYear,IssuerId
FROM PlanAttributes
GROUP BY PlanId,BusinessYear,IssuerId


-- Check PlanId entries in Rate for a sample IssuerId (10046)
SELECT PlanId,BusinessYear,IssuerId
FROM Rate
WHERE IssuerId = 10046
GROUP BY PlanId


-- Total row counts across all six marketplace tables
SELECT 'Rate' AS table_name, COUNT(*) AS total_rows 
FROM Rate
UNION ALL
SELECT 'PlanAttributes', COUNT(*) 
FROM PlanAttributes
UNION ALL
SELECT 'BenefitsCostSharing', COUNT(*) 
FROM BenefitsCostSharing
UNION ALL
SELECT 'ServiceArea', COUNT(*) 
FROM ServiceArea
UNION ALL
SELECT 'Network', COUNT(*)
FROM Network
UNION ALL
SELECT 'BusinessRules', COUNT(*)
FROM BusinessRules;


-- Coverage summary: year range, distinct states, issuers, and plans in Rate
SELECT 
    MIN(BusinessYear) AS start_year,
    MAX(BusinessYear) AS end_year,
    COUNT(DISTINCT StateCode) AS total_states,
    COUNT(DISTINCT IssuerId) AS total_issuers,
    COUNT(DISTINCT PlanId) AS total_plans
FROM Rate;


-- Inspect IndividualRate for nulls, zeros, and basic range (pre-cleaning)
SELECT 
    MIN(IndividualRate) AS min_rate,
    AVG(IndividualRate) AS avg_rate,
    MAX(IndividualRate) AS max_rate,
    COUNT(CASE WHEN IndividualRate IS NULL THEN 1 END) AS null_rates,
    COUNT(CASE WHEN IndividualRate = 0 THEN 1 END) AS zero_rates
FROM Rate;


-- Investigate outlier IndividualRate values above 10,000
SELECT
    BusinessYear,
    StateCode,
    IssuerId,
    PlanId,
    Age,
    IndividualRate
FROM Rate
WHERE IndividualRate > 10000
ORDER BY IndividualRate DESC
LIMIT 10;


-- Count rows where IndividualRate is the 999999 sentinel value
SELECT 
    IssuerId, 
    StateCode, 
    BusinessYear, 
    COUNT(*) as sentinel_count
FROM Rate
WHERE IndividualRate = 999999
GROUP BY IssuerId, StateCode, BusinessYear
ORDER BY sentinel_count DESC;


-- Recalculate rate statistics after excluding sentinel/placeholder values
SELECT 
    MIN(IndividualRate) AS min_clean_rate,
    ROUND(AVG(IndividualRate), 2) AS avg_clean_rate,
    MAX(IndividualRate) AS max_clean_rate,
    COUNT(*) AS valid_record_count,
    COUNT(CASE WHEN IndividualRate IS NULL THEN 1 END) AS null_rates,
    COUNT(CASE WHEN IndividualRate = 0 THEN 1 END) AS zero_rates
FROM Rate
WHERE IndividualRate >= 10.00 
AND IndividualRate NOT IN (9999.99, 9999, 99999, 999999);


-- Check PlanId completeness (nulls) in PlanAttributes
SELECT
    COUNT(*) AS total_records,
    COUNT(PlanId) AS plan_id_count,
    COUNT(CASE WHEN PlanId IS NULL THEN 1 END) AS null_plan_count
FROM PlanAttributes


-- Compare StandardComponentId in PlanAttributes vs PlanId in Rate (sample)
SELECT
    BusinessYear,
    StateCode,
    IssuerId,
    PlanId,
    StandardComponentId
FROM PlanAttributes
LIMIT 10;


-- Preview PlanId values directly from Rate (sample)
SELECT
    BusinessYear,
    StateCode,
    IssuerId,
    PlanId
FROM Rate
LIMIT 10;


-- Safe LEFT JOIN of Rate and PlanAttributes for a single state/year (AK, 2014)
SELECT 
    r.BusinessYear, r.StateCode, r.IssuerId, r.PlanId,
    r.Age, r.IndividualRate,
    p.StandardComponentId,
    p.PlanMarketingName, p.PlanType,
    p.ServiceAreaId, p.NetworkId
FROM Rate r
LEFT JOIN PlanAttributes p
    ON r.PlanId = p.StandardComponentId
    AND p.PlanId LIKE '%-01'
    AND r.IssuerId = p.IssuerId
    AND r.StateCode = p.StateCode
    AND r.BusinessYear = p.BusinessYear
WHERE r.StateCode = 'AK' AND r.BusinessYear = 2014


-- Summary statistics for Age and IndividualRate after cleaning
SELECT
    COUNT(*) AS total_records, 
    ROUND(AVG(CASE WHEN Age NOT IN ('Family Option', '0-20') THEN CAST(Age AS INTEGER) END),2) AS avg_age,
    ROUND(AVG(IndividualRate), 2) AS mean_rate,
    ROUND(MIN(IndividualRate), 2) AS min_rate,
    ROUND(MAX(IndividualRate), 2) AS max_rate
FROM Rate
WHERE IndividualRate >= 10.00 
AND IndividualRate NOT IN (9999.99, 9999, 99999, 999999);


-- Distribution and percentage breakdown of PlanType in PlanAttributes
SELECT 
    PlanType,
    COUNT(*) AS total_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM PlanAttributes WHERE PlanType IS NOT NULL), 2) AS percentage
FROM PlanAttributes
GROUP BY PlanType
ORDER BY total_count DESC;


-- Full cleaned join of Rate and PlanAttributes (deduplicated variant), used for EDA
SELECT 
    r.BusinessYear,
    r.StateCode,
    r.Age,
    r.IndividualRate,
    p.MetalLevel,
    p.PlanType
FROM Rate r
LEFT JOIN (SELECT DISTINCT
        StandardComponentId, 
        IssuerId, 
        StateCode, 
        BusinessYear, 
        MetalLevel, 
        PlanType
    FROM PlanAttributes
    WHERE PlanId LIKE '%-01') p
    ON r.PlanId = p.StandardComponentId
    AND r.IssuerId = p.IssuerId
    AND r.StateCode = p.StateCode
    AND r.BusinessYear = p.BusinessYear
WHERE r.IndividualRate >= 10.00  
    AND IndividualRate NOT IN (9999.99, 9999, 99999, 999999);


-- Average/median/min/max premium by StateCode and RatingAreaId (rating areas with 10+ records)
SELECT StateCode, RatingAreaId, IndividualRate
    FROM Rate
    WHERE IndividualRate >= 10.00
    AND IndividualRate NOT IN (9990.00, 9999, 99999, 999999)


-- Pull Age/Tobacco/IndividualRate data from Rate for market relationship analysis
SELECT 
                                Age, 
                                Tobacco, 
                                IndividualRate, 
                                IndividualTobaccoRate,
                                r.PlanId, 
                                r.IssuerId, 
                                r.StateCode, 
                                r.BusinessYear
    FROM Rate r
    WHERE IndividualRate >= 10.00
    AND IndividualRate NOT IN (9999.99, 9999, 99999, 999999)


-- Lookup distinct MetalLevel by plan (standard component, '00' variant) from PlanAttributes
SELECT DISTINCT 
                                            StandardComponentId, 
                                            IssuerId, 
                                            StateCode, 
                                            BusinessYear, 
                                            MetalLevel
    FROM PlanAttributes
    WHERE SUBSTR(PlanId, -2) = '00'

