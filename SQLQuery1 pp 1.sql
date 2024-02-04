--looking at the total cases vs total death
--Showing percentage of people that got covid in Nigeria
SELECT location, date,total_cases,total_deaths,population,(CAST(total_deaths as float) / CAST(total_cases as float))*100 as PercentageOfPeopleInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and total_cases is not null and total_deaths is not null and location like '%nigeria%'
ORDER BY 1,2

--looking at countries with the highest infection rate compare to population

SELECT location,MAX(total_cases) as HighestInfectionCount, population, Max((cast(total_cases as float))/ population)*100 as PercentageOfPeopleInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and total_cases is not null and total_deaths is not null 
GROUP BY location,population
ORDER BY  PercentageOfPeopleInfected DESC

--Looking at country with the highest death count per the population

SELECT location,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and total_cases is not null and total_deaths is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC

--Lets break things down by continent

--Showing the continent with the highest death count

SELECT location,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null 
GROUP BY location
ORDER BY TotalDeathCount DESC


--Global Numbers


SELECT date,SUM(CAST(new_cases as float))as TotalCases, SUM(CAST(new_deaths as float))as TotalDeath,(SUM(CAST(new_deaths as float)) / SUM(CAST(new_cases as float)))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is null 
GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccination


SELECT DEA.continent, DEA.location,DEA.date,population, VAC.new_vaccinations, SUM(CONVERT(float,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date)as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccination VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent is not null and dea.location like '%NIGERIA%' AND population is not null and VAC.new_vaccinations IS NOT NULL
ORDER BY 1,2



--USING CTE to find the percentage of people vaccinated

WITH POPVSVAC
AS
(
SELECT DEA.continent, DEA.location,DEA.date,population, VAC.new_vaccinations, SUM(CONVERT(float,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date)as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccination VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent is not null AND population is not null and VAC.new_vaccinations IS NOT NULL
)

SELECT *,(RollingPeopleVaccination/population)*100 as PercentageOfPeopleVaccinated
FROM POPVSVAC


-- USING TEMP TABLE to find the percentage of people vaccinated

Drop table if exists #PercentageOfPeopleVaccinated
CREATE TABLE #PercentageOfPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccination numeric
)

INSERT INTO #PercentageOfPeopleVaccinated
SELECT DEA.continent, DEA.location,DEA.date,population, VAC.new_vaccinations, SUM(CONVERT(float,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date)as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccination VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent is not null AND population is not null and VAC.new_vaccinations IS NOT NULL

SELECT *,(RollingPeopleVaccination/population)*100 as PercentageOfPeopleVaccinated
FROM #PercentageOfPeopleVaccinated


CREATE VIEW PercentageOfPeopleVaccinated AS
SELECT DEA.continent, DEA.location,DEA.date,population, VAC.new_vaccinations, SUM(CONVERT(float,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date)as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccination VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent is not null AND population is not null and VAC.new_vaccinations IS NOT NULL