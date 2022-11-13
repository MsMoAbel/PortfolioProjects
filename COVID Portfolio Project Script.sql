SELECT *
FROM "Portfolio Project"..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM "Portfolio Project"..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we will be using

SELECT location, date, continent, total_cases, new_cases, total_deaths, population
FROM "Portfolio Project"..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT location, date, continent, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM "Portfolio Project"..CovidDeaths$
WHERE location like '%kingdom%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases VS  Population
-- Shows what percentage of population got Covid

SELECT location, date, continent,  population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM "Portfolio Project"..CovidDeaths$
--WHERE location like '%kingdom%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, continent, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM "Portfolio Project"..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with Highest Death Count

SELECT location, continent, MAX(CAST(total_deaths as int)) AS HighestDeathCount
FROM "Portfolio Project"..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- A Breakdown By Continent

SELECT location, continent, MAX(CAST(total_deaths as int)) AS HighestDeathCount
FROM "Portfolio Project"..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Showing continents with the Highest Death Count

SELECT continent, MAX(CAST(total_deaths as int)) AS HighestDeathCount
FROM "Portfolio Project"..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- GLOBAL NUMBERS

SELECT date,  SUM(new_cases) AS total_Cases, SUM(CAST(new_deaths as int)) AS total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM "Portfolio Project"..CovidDeaths$
--WHERE location like '%kingdom%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Joins
-- Looking at Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummVaccinationCount
FROM "Portfolio Project"..CovidDeaths$ dea
 JOIN "Portfolio Project"..CovidVaccinations$ vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, CummVaccinationCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummVaccinationCount
FROM "Portfolio Project"..CovidDeaths$ dea
 JOIN "Portfolio Project"..CovidVaccinations$ vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT*, (CummVaccinationCount/population)*100
FROM PopvsVac

-- Use Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
CummVaccinationCount numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummVaccinationCount
FROM "Portfolio Project"..CovidDeaths$ dea
 JOIN "Portfolio Project"..CovidVaccinations$ vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null

SELECT*, (CummVaccinationCount/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

--DROP VIEW PercentPopulationVaccinated

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummVaccinationCount
FROM "Portfolio Project"..CovidDeaths$ dea
 JOIN "Portfolio Project"..CovidVaccinations$ vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null