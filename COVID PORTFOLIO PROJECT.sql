--Select the Data to be Used--
SELECT location, date, total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths--
--Likelihood of Dying if Infected by Covid--
SELECT location, 
       date, 
	   total_cases,
	   total_deaths,
	   CASE
	   WHEN CAST (total_cases as float)=0 THEN 0
	 ELSE(CAST(total_deaths AS float)/
	   CAST(total_cases AS float))*100 
	   END as DeathPercentage
FROM CovidDeaths
WHERE location like '%NIGERIA%' 
ORDER BY location,date

--Looking at Total Cases vs Population--
--Shows the Percentage of Population Infected with Covid--
SELECT location, 
       date, 
	   total_cases,
	   population,
	   CASE
      WHEN CAST (total_cases AS float)=0 THEN 0
	 ELSE(CAST(total_cases AS float)/
	   CAST(population AS float))*100 
	   END AS CovidPopPercentage
FROM CovidDeaths
WHERE location like '%NIGERIA%'
ORDER BY location,date

--Looking at Countries with Highest Infection Rate Compared to Population--
SELECT location, 
	   population,
	  MAX(total_cases) AS HighestInfectionCount,
	  CASE
      WHEN CAST(total_cases AS float)=0 THEN 0
	 ELSE(CAST(total_cases AS float)/
	   CAST(population AS float))*100 
	   END AS HighestCovidPercent
 FROM CovidDeaths
GROUP BY population,total_cases,location
ORDER BY HighestCovidPercent desc

--Showing Countries With Highest Death Count Per Population--
SELECT location, 
	  MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing Continents With The Highest Death Count--
SELECT continent, 
	  MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers--
SELECT 
       date, 
	   SUM(CAST(new_cases as int))as total_cases,
	   SUM(CAST(new_deaths as int))as total_deaths,
	   CASE
	   WHEN CAST(new_cases as float)=0 THEN 0
	   ELSE CAST(new_deaths as float)/CAST(new_cases as float)*100 
	   END AS DeathPercentage 
FROM CovidDeaths
WHERE continent is not null
GROUP BY date,new_cases,new_deaths
ORDER BY  DeathPercentage desc

--Looking at Total Population vs Vaccination--

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)as PeopleVaccinated,
  CASE
	   WHEN CAST(new_vaccinations as float)=0 THEN 0
	   ELSE CAST(new_vaccinations as float)
	   END AS new_vaccinations
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE--
WITH PopvsVac(continent,location,date,population,new_vaccinations,PeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,
  SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)as PeopleVaccinated,
  CASE
	   WHEN CAST(new_vaccinations as float)=0 THEN 0
	   ELSE CAST(new_vaccinations as float)
	   END AS new_vaccinations
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
)
SELECT *,(PeopleVaccinated/population)*100
FROM PopvsVac

--Temp Table--

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent varchar(50),
location varchar(50),
date varchar(50),
population varchar(50),
new_vaccinations varchar(50),
PeopleVaccinated varchar(50)
)
SELECT *
FROM #PercentPopulationVaccinated

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,
  SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)as PeopleVaccinated,
  CASE
	   WHEN CAST(new_vaccinations as float)=0 THEN 0
	   ELSE CAST(new_vaccinations as float)
	   END AS new_vaccinations
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null

SELECT *
FROM #PercentPopulationVaccinated

--Creating View to Store Data for Visualization--
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent,dea.location,dea.date,dea.population,
  SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)as PeopleVaccinated,
  CASE
	   WHEN CAST(new_vaccinations as float)=0 THEN 0
	   ELSE CAST(new_vaccinations as float)
	   END AS new_vaccinations
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated

