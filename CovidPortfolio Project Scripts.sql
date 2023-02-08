Select * from Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4;

/*Select * from Portfolio_Project..CovidVaccinations
order by 3,4*/

Select location , date ,total_cases , new_cases , total_deaths,population  
from CovidDeaths
order by 1,2;

-- Cases to Death Comparison
Select location , date ,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathToCasesRatio    
from CovidDeaths
where location like '%india'
order by 1,2
--By 6th of February 2023 , the DCR Ratio is 1.1877

-- Total Cases VS Population Comparison  
Select location , date ,total_cases, population, (total_cases/Population)*100 as InfectedPopulationRatio    
from CovidDeaths
where location like '%india%'
order by 1,2

-- Countries with highest infection rate compared to Population
Select Location , population ,MAX(total_cases) as MaximumInfectionCount, 
MAX((total_cases/Population))*100 as PercentPopulationInfected    
from CovidDeaths
group by Location , Population
order by PercentPopulationInfected desc 


-- Countries with Maximum Deaths per population
Select Location ,MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by Location 
order by TotalDeathCount desc 


-- AGGREGATING highest death count ON CONTINENT BASIS
Select continent ,MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent 
order by TotalDeathCount desc 

-- Global Numbers
Select date ,SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as DeathToCaseRatio
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- Covid Vaccination Database
Select * 
from [dbo].[CovidVaccinations];


Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(V.new_vaccinations as BIGint)) 
OVER (PARTITION BY D.Location ORDER BY D.LOCATION , D.DATE) AS ROLLING_PEOPLE_VACCINATED
-- (ROLLING_PEOPLE_VACCINATED/POPULATION)*100
from [dbo].[CovidDeaths] D
Join [dbo].[CovidVaccinations] V
on D.location = V.location
and D.date = V.date
where D.continent IS NOT null
order by 2,3

-- USE CTE
with PopvsVac(Continent , Location , Date , Population , New_Vaccinations , ROLLING_PEOPLE_VACCINATED)
as
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(V.new_vaccinations as BIGint)) 
OVER (PARTITION BY D.Location ORDER BY D.LOCATION , D.DATE) AS ROLLING_PEOPLE_VACCINATED
-- (ROLLING_PEOPLE_VACCINATED/POPULATION)*100
from [dbo].[CovidDeaths] D
Join [dbo].[CovidVaccinations] V
on D.location = V.location
and D.date = V.date
where D.continent IS NOT null
)
SELECT * , (ROLLING_PEOPLE_VACCINATED/POPULATION)*100
FROM PopvsVac

-- TEMP TABLES

-- DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(CONTINENT nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
ROLLING_PEOPLE_VACCINATED numeric
)

INSERT INTO #PERCENTPOPULATIONVACCINATED
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(V.new_vaccinations as BIGint)) 
OVER (PARTITION BY D.Location ORDER BY D.LOCATION , D.DATE) AS ROLLING_PEOPLE_VACCINATED
-- (ROLLING_PEOPLE_VACCINATED/POPULATION)*100
from [dbo].[CovidDeaths] D
Join [dbo].[CovidVaccinations] V
on D.location = V.location
and D.date = V.date
where D.continent IS NOT null


SELECT * , (ROLLING_PEOPLE_VACCINATED/POPULATION)*100
FROM #PERCENTPOPULATIONVACCINATED;

-- You can use drop table to create the same table once again

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PERCENTPOPULATIONVACCINATED AS 
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(V.new_vaccinations as BIGint)) 
OVER (PARTITION BY D.Location ORDER BY D.LOCATION , D.DATE) AS ROLLING_PEOPLE_VACCINATED
-- (ROLLING_PEOPLE_VACCINATED/POPULATION)*100
from [dbo].[CovidDeaths] D
Join [dbo].[CovidVaccinations] V
on D.location = V.location
and D.date = V.date
where D.continent IS NOT null

Select * from PERCENTPOPULATIONVACCINATED