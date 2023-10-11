
Use PortfolioProject;

Select *
from CovidDeaths
order by 3,4

Select *
from CovidVaccinations
order by 3,4


SELECT location, date, population, total_cases, new_cases, total_deaths 
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country
SELECT location
, date
, total_cases
, total_deaths 
, cast((cast(total_deaths as float)/cast(total_cases as float)) * 100 as Decimal(10,4)) DeathPercentage
FROM CovidDeaths
WHERE location like '%India%'
and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location
, date
, population
, total_cases
, cast((cast(total_cases as float)/cast(population as float)) * 100 as Decimal(10,4)) InfectedPopulationPercentage
FROM CovidDeaths
where continent is not null
--and location like '%India%'
ORDER BY 1,2 


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location
, population
, Max(cast(total_cases as float)) as HighestInfectionCount
, cast(max(cast(total_cases as float)/cast(population as float)) * 100 as Decimal(10,4)) InfectedPopulationPercentage
FROM CovidDeaths
where continent is not null
--and location like '%India%'
GROUP BY location, population
ORDER BY 4 DESC


-- Looking at the Countries with Highest Death Count
SELECT location
, Max(cast(total_deaths as float)) as HighestDeathCount
FROM CovidDeaths
where continent is not null
GROUP BY location
ORDER BY 2 DESC


-- Showing the Continents with Highest Death Count
SELECT continent
, Max(cast(total_deaths as float)) as TotalDeathCount
FROM CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY 2 DESC


-- Global Death Percentage by Days

SELECT date
,sum(new_cases) as GlobalNewCases
,Sum(cast(new_deaths as int)) as GlobalDeathCount
,cast(CASE WHEN sum(new_cases) = 0 THEN 0 ELSE Sum(cast(new_deaths as int))/sum(new_cases) * 100 END as decimal(10,4)) GlobalDeathPercentage
FROM CovidDeaths
where continent is not null
GROUP BY date
ORDER BY 1


-- Global Death Percentage

SELECT sum(new_cases) as GlobalNewCases
,Sum(cast(new_deaths as int)) as GlobalDeathCount
,cast(CASE WHEN sum(new_cases) = 0 THEN 0 ELSE Sum(cast(new_deaths as int))/sum(new_cases) * 100 END as decimal(10,4)) GlobalDeathPercentage
FROM CovidDeaths
where continent is not null


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(Case when vac.new_vaccinations is NULL THEN 0 ELSE vac.new_vaccinations END as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE
With PopvsVac  (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *
,(RollingPeopleVaccinated/ population) * 100 as VaccinatedPopulationPercentage
from PopvsVac


-- TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
,(RollingPeopleVaccinated/ population) * 100 as VaccinatedPopulationPercentage
from #PercentPopulationVaccinated


-- CREATING VIEWS
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated