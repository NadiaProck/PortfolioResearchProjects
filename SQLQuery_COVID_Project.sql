--See your imported data
SELECT *
FROM [Portfolio COVID].dbo.CovidDeaths
ORDER BY 3, 4

SELECT *
FROM [Portfolio COVID].dbo.CovidVaccinations
ORDER BY 3, 4

--Select data from main table data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio COVID].dbo.CovidDeaths
order by 1, 2

--Calculation from selected table
----Calculating the Death Percentage as Total Cases vs Total Deaths at CovidDeaths table

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio COVID].dbo.CovidDeaths
order by 1, 2

----Calculating the Death Percentage as (Total Cases vs Total Deaths)*100 at CovidDeaths table
-------for a selected country Germany

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio COVID].dbo.CovidDeaths
WHERE location like '%ermany%'
order by 1, 2

--Calculation from selected table
----Calculating the Infected Percentage as Total Cases vs Total Population at CovidDeaths table
------for a selected country Germany

SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 as Percentage_Infected_Population
FROM [Portfolio COVID].dbo.CovidDeaths
WHERE location like '%ermany%'
ORDER BY 1, 2

--Calculation from selected table 
----Selecting countries with the highest percentage of infected people
SELECT location, population, MAX(total_cases) as Highest_#ofInfected_People, MAX((total_cases/population))*100 as Highest_Percentage_Infected_Population
FROM [Portfolio COVID].dbo.CovidDeaths
GROUP BY location, population
ORDER BY Highest_Percentage_Infected_Population desc

--Calculation from selected table
----Selecting countries with the highest #of dead people
SELECT location, MAX(cast(total_deaths as int)) as Highest_#ofDeath_People
--cast changes the total_deaths to a numerical value
FROM [Portfolio COVID].dbo.CovidDeaths
WHERE continent is not NULL
--by commanding continent is not NULL, we remove the rows where continents are listed, we only want to select countries
GROUP BY location
ORDER BY Highest_#ofDeath_People desc

--Calculation from selected table 
----Selecting continents with the highest #of dead people
SELECT location, MAX(cast(total_deaths as int)) as Highest_#ofDeath_People
FROM [Portfolio Research Data Analyst].dbo.CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY Highest_#ofDeath_People desc

----Joining two tables in SQL
SELECT *
FROM [Portfolio COVID].dbo.CovidDeaths as dea
JOIN [Portfolio COVID].dbo.CovidVaccinations as vac
--as is used to abbreviate the large dataset name
ON dea.location = vac.location 
AND dea.date = vac.date


---------------RESEARCH QUESTION-------------------------
--------------1) How many total deaths have in average different categories of countries based on their GPD_per_capita?

----Show the gpd_per_capita for each listed country
SELECT location, gdp_per_capita
FROM [Portfolio COVID].dbo.CovidDeaths
WHERE continent is not NULL
---Eliminates the rows that include continents instead of individual countries
GROUP BY location, gdp_per_capita
ORDER BY gdp_per_capita desc


----------Categorizing the gpd_per_capita into 5 categories as follows:
------------Very High-Income Countries:
    --    GDP per capita: $40,000 or more (approximately)
    --    These countries typically have a very high standard of living, advanced infrastructure, and strong economies.

    --High-Income Countries:
    --    GDP per capita: $12,696 to $39,999 (approximately)
    --    High-income countries have a strong economy and a good standard of living but may not be at the very top in terms of wealth.

    --Upper-Middle-Income Countries:
    --    GDP per capita: $4,096 to $12,695 (approximately)
    --    These countries are economically developed but not as wealthy as high-income nations.

    --Lower-Middle-Income Countries:
    --    GDP per capita: $1,046 to $4,095 (approximately)
    --    Lower-middle-income countries are in the process of economic development and may have growing industries.

    --Low-Income Countries:
    --    GDP per capita: $1,045 or less (approximately)
    --    Low-income countries are typically characterized by lower standards of living, less developed infrastructure, and economic challenges.

	-------gdp not available

SELECT location, gdp_per_capita,
    CASE
        WHEN gdp_per_capita < 1045 THEN 'Low_Income Countries'
        WHEN gdp_per_capita >= 1046 AND gdp_per_capita < 4095 THEN 'Lower-Middle-Income Countries'
        WHEN gdp_per_capita >= 4096 AND gdp_per_capita < 12695 THEN 'Upper-Middle-Income Countries'
        WHEN gdp_per_capita >= 12696 AND gdp_per_capita < 39999 THEN 'High-Income Countries'
		WHEN gdp_per_capita >= 40000 AND gdp_per_capita < 20000000 THEN 'Very High-Income Countries' 
        ELSE 'gdp not available'
    END AS category
FROM [Portfolio COVID].dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location, gdp_per_capita
ORDER BY gdp_per_capita desc


------------Adding the total_deaths to the above results
---------------the total_deaths is labelled as a nvarchar, we need to convert to an int since it does not contains decimals
----------------now we convert the nvarchar column to int type
---------------we can check if we have values which are not numeric = 0 = false; 1 = TRUE

SELECT total_deaths
FROM [Portfolio COVID].dbo.CovidDeaths
WHERE ISNUMERIC(total_deaths) = 0 OR ISNUMERIC(total_deaths) = 1

---We can convert the total_deaths as int type to input in our previous analyses

SELECT location, MAX(CAST(total_deaths as int)) as Max#deaths, gdp_per_capita,
    CASE
        WHEN gdp_per_capita < 1045 THEN 'Low_Income Countries'
        WHEN gdp_per_capita >= 1046 AND gdp_per_capita < 4095 THEN 'Lower-Middle-Income Countries'
        WHEN gdp_per_capita >= 4096 AND gdp_per_capita < 12695 THEN 'Upper-Middle-Income Countries'
        WHEN gdp_per_capita >= 12696 AND gdp_per_capita < 39999 THEN 'High-Income Countries'
		WHEN gdp_per_capita >= 40000 AND gdp_per_capita < 20000000 THEN 'Very High-Income Countries' 
        ELSE 'gdp not available'
    END AS category
FROM [Portfolio COVID].dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location, gdp_per_capita
ORDER BY gdp_per_capita desc

---Now we can see the gdp_per_capita of each country and the max#deaths! Great! 
---We answered our initial research question. 

---**************************************Now lets take one step further to check the following hypothesis************************************
---HYPOTHESIS: Is the higher gdp category of a country related to a lower total death?
-- Firs we create a CTE with our previous query in order to create a temporary table with our previous output

WITH GDP_vs_TotalDeaths (location, Max_deaths, gdp_per_capita, category) 
AS 
(
SELECT location, MAX(CAST(total_deaths as int)) as Max_deaths, gdp_per_capita,
    CASE
        WHEN gdp_per_capita < 1045 THEN 'Low_Income Countries'
        WHEN gdp_per_capita >= 1046 AND gdp_per_capita < 4095 THEN 'Lower-Middle-Income Countries'
        WHEN gdp_per_capita >= 4096 AND gdp_per_capita < 12695 THEN 'Upper-Middle-Income Countries'
        WHEN gdp_per_capita >= 12696 AND gdp_per_capita < 39999 THEN 'High-Income Countries'
		WHEN gdp_per_capita >= 40000 AND gdp_per_capita < 20000000 THEN 'Very High-Income Countries' 
        ELSE 'gdp not available'
    END AS category
FROM [Portfolio COVID].dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location, gdp_per_capita
)
-- The below step must be included in the create temporary table
SELECT*
FROM GDP_vs_TotalDeaths
ORDER BY Max_deaths desc

---------Calculate the average total deaths per GDP category
----we will need to create a CTE to calculate the AVERAGE death after first calculating the Maximum total deaths per location
----The calculation of Maximum total deaths per location is first computed within the "WITH CTE AS ()" function,
---then on the next level on the SELECT option, we can calculate the AVERAGE death per location
WITH GDP_vs_TotalDeaths (location, Max_deaths, gdp_per_capita, category) 
AS 
(
SELECT location, MAX(CAST(total_deaths as int)) as Max_deaths, gdp_per_capita,
    CASE
        WHEN gdp_per_capita < 1045 THEN 'Low_Income Countries'
        WHEN gdp_per_capita >= 1046 AND gdp_per_capita < 4095 THEN 'Lower-Middle-Income Countries'
        WHEN gdp_per_capita >= 4096 AND gdp_per_capita < 12695 THEN 'Upper-Middle-Income Countries'
        WHEN gdp_per_capita >= 12696 AND gdp_per_capita < 39999 THEN 'High-Income Countries'
		WHEN gdp_per_capita >= 40000 AND gdp_per_capita < 20000000 THEN 'Very High-Income Countries' 
        ELSE 'gdp not available'
    END AS category
FROM [Portfolio COVID].dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location, gdp_per_capita
)
-- The below step MUST be included to create a CTE table
SELECT category, AVG(Max_deaths) as Average_deaths
FROM GDP_vs_TotalDeaths
GROUP BY category
ORDER BY 2 desc



-----As the data shows, our hypothesis is FALSE. We found out that the richer countries had a higher number of deaths due to COVID. 
-----We could continue our assesment and test the following hypothesis: 
-----* Richer countries had a larger life expectancy, thus a higher percentage of population on the risk age for COVID? This could explain
-----the higher number of people associated to richer countries.
-----* Poor countries were not as efficient as registering COVID deaths as countries with a higher GDP? We will need additional data 
-----to answer this question.

-----Instead of digging deeper into details that would help us to explain the above findings,
------we will explore another research question:
-----2) Does countries with a higher GDP have a higher number of vaccinated people (>= 1 vaccine dose)?

---First, we will join our two main datasets

SELECT *
FROM [Portfolio COVID].dbo.CovidDeaths as dea
JOIN [Portfolio COVID].dbo.CovidVaccinations as vac
--as is used to abbreviate the large dataset name
ON dea.location = vac.location 
AND dea.date = vac.date

---We now select our desired columns

SELECT dea.location, MAX(cast(vac.people_vaccinated as int)) as Total_People_vaccinated, dea.gdp_per_capita,
CASE
        WHEN dea.gdp_per_capita < 1045 THEN 'Low_Income Countries'
        WHEN dea.gdp_per_capita >= 1046 AND dea.gdp_per_capita < 4095 THEN 'Lower-Middle-Income Countries'
        WHEN dea.gdp_per_capita >= 4096 AND dea.gdp_per_capita < 12695 THEN 'Upper-Middle-Income Countries'
        WHEN dea.gdp_per_capita >= 12696 AND dea.gdp_per_capita < 39999 THEN 'High-Income Countries'
		WHEN dea.gdp_per_capita >= 40000 AND dea.gdp_per_capita < 20000000 THEN 'Very High-Income Countries' 
        ELSE 'gdp not available'
    END AS category
FROM [Portfolio COVID].dbo.CovidDeaths as dea
JOIN [Portfolio COVID].dbo.CovidVaccinations as vac
--as is used to abbreviate the large dataset name
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not NULL
GROUP BY dea.location, dea.gdp_per_capita
ORDER BY 2 desc

--Wonderful, now we can see how many people got vaccinated per country! So lets answer our hypothesis in the following steps:
-- This time instead of creating a CTE table, we will create a temporary table

DROP TABLE if exists #GDP_vs_TotalVaccinated 
CREATE TABLE #GDP_vs_TotalVaccinated
( location nvarchar (255),
Total_People_vaccinated numeric,
gdp_per_capita numeric,
category nvarchar(255)
)
INSERT INTO #GDP_vs_TotalVaccinated 
SELECT dea.location, MAX(cast(vac.people_vaccinated as int)) as Total_People_vaccinated, dea.gdp_per_capita,
CASE
        WHEN dea.gdp_per_capita < 1045 THEN 'Low_Income Countries'
        WHEN dea.gdp_per_capita >= 1046 AND dea.gdp_per_capita < 4095 THEN 'Lower-Middle-Income Countries'
        WHEN dea.gdp_per_capita >= 4096 AND dea.gdp_per_capita < 12695 THEN 'Upper-Middle-Income Countries'
        WHEN dea.gdp_per_capita >= 12696 AND dea.gdp_per_capita < 39999 THEN 'High-Income Countries'
		WHEN dea.gdp_per_capita >= 40000 AND dea.gdp_per_capita < 20000000 THEN 'Very High-Income Countries' 
        ELSE 'gdp not available'
    END AS category
FROM [Portfolio COVID].dbo.CovidDeaths as dea
JOIN [Portfolio COVID].dbo.CovidVaccinations as vac
--as is used to abbreviate the large dataset name
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not NULL
GROUP BY dea.location, dea.gdp_per_capita
--the below step MUST be included to call your temporary table 
SELECT *
FROM #GDP_vs_TotalVaccinated
ORDER BY 2 desc


---------Calculate the average total people vaccinated per GDP category

SELECT category, AVG(Total_People_vaccinated) as Average_People_Vaccinated
FROM #GDP_vs_TotalVaccinated
GROUP BY category
ORDER BY 2 desc

-----As the data shows, our hypothesis is TRUE. We found out that the richer countries (higher GDP) had a higher number of vaccinated people.

--All in all, countries with high GDP reported a higher number of deaths from 2019 until 2021 due to COVID. Once the vaccination campaing started,
--richer countries were able to vaccinate a higher number of people.

--***************On OUR FINAL STEP WE WANT TO VISUALIZE SOME OF OUR RESULTS**************************
---------Lets create views!
-----I would start by creating a view to help us answer our first research question
----1) How many total deaths have in average different categories of countries based on their GPD_per_capita?
-----On the query below we were able to calculate the gdp_per_capita of each country and their max#deaths,
---so lets create a view out of that output.

CREATE VIEW GDPvsTotalDeaths AS 
SELECT location, MAX(CAST(total_deaths as int)) as Max#deaths, gdp_per_capita,
    CASE
        WHEN gdp_per_capita < 1045 THEN 'Low_Income Countries'
        WHEN gdp_per_capita >= 1046 AND gdp_per_capita < 4095 THEN 'Lower-Middle-Income Countries'
        WHEN gdp_per_capita >= 4096 AND gdp_per_capita < 12695 THEN 'Upper-Middle-Income Countries'
        WHEN gdp_per_capita >= 12696 AND gdp_per_capita < 39999 THEN 'High-Income Countries'
		WHEN gdp_per_capita >= 40000 AND gdp_per_capita < 20000000 THEN 'Very High-Income Countries' 
        ELSE 'gdp not available'
    END AS category
FROM [Portfolio COVID].dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location, gdp_per_capita
--ORDER BY gdp_per_capita desc

----THANKS for checking at my SQL script. I hope that you enjoy this script. Feel free to contact me in case of further questions :)




