-- ============================================================
-- Emissions Dashboard Queries (EPA 2023 Data)
-- Author: Maryam
-- Purpose: SQL queries powering Databricks dashboard visualizations
-- ============================================================

-- ------------------------------------------------------------
-- Query 1: Geospatial Emissions Mapping
-- Used for: Point Map ("Emissions for Continental US")
-- ------------------------------------------------------------
SELECT 
    latitude,
    longitude,
    `GHG emissions mtons CO2e` AS Emissions
FROM emissions.default.emissions_data;


-- ------------------------------------------------------------
-- Query 2: Emissions Per Person by County
-- Used for: Scatter plot ("Emission vs Population")
-- ------------------------------------------------------------
SELECT 
    county_state_name,
    population,
    CAST(REPLACE(`GHG emissions mtons CO2e`, ',', '') AS DOUBLE) /
    CAST(REPLACE(population, ',', '') AS DOUBLE) AS Emissions_per_person
FROM emissions.default.emissions_data
ORDER BY Emissions_per_person DESC;


-- ------------------------------------------------------------
-- Query 3: Top 10 States by Total Emissions
-- Used for: Pie Plot ("Emissions of Top 10 States")
-- ------------------------------------------------------------
SELECT 
    state_abbr,
    SUM(CAST(REPLACE(`GHG emissions mtons CO2e`, ',', '') AS DOUBLE)) AS Total_Emissions
FROM emissions.default.emissions_data
GROUP BY state_abbr
ORDER BY Total_Emissions DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Query 4: Top 10 Counties by Total Emissions
-- Used for: Bar Plot ("Top Counties by Emissions")
-- ------------------------------------------------------------
SELECT 
    county_state_name,
    SUM(CAST(REPLACE(`GHG emissions mtons CO2e`, ',', '') AS DOUBLE)) AS Total_Emissions
FROM emissions.default.emissions_data
GROUP BY county_state_name
ORDER BY Total_Emissions DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Query 5: Aggregate Contribution of Top 10 States
-- ------------------------------------------------------------
WITH state_totals AS (
    SELECT
        state_abbr,
        SUM(CAST(REPLACE(`GHG emissions mtons CO2e`, ',', '') AS DOUBLE)) AS total_emissions
    FROM emissions.default.emissions_data
    GROUP BY state_abbr
),
us_total AS (
    SELECT
        SUM(CAST(REPLACE(`GHG emissions mtons CO2e`, ',', '') AS DOUBLE)) AS us_emissions
    FROM emissions.default.emissions_data
),
top_10 AS (
    SELECT
        st.state_abbr,
        st.total_emissions,
        (st.total_emissions / ut.us_emissions) * 100 AS pct_of_us
    FROM state_totals st
    CROSS JOIN us_total ut
    ORDER BY st.total_emissions DESC
    LIMIT 10
),
agg AS (
    SELECT
        SUM(total_emissions) AS total_emissions_top_10,
        SUM(pct_of_us) AS pct_top_10
    FROM top_10
)
SELECT
    total_emissions_top_10,
    pct_top_10
FROM agg;

-- ============================================================
-- End of queries.sql
-- ============================================================