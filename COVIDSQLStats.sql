
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- shows overall mortality rate of COVID for US at a given date

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE Location like '%states%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at total Cases vs Population
-- Percentage of population whom have contracted COVID for US

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CovidPopulationPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE Location like '%states%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, Max(total_cases) as TotalInfectionCount, ( Max(total_cases)/Max(population))*100 AS TotalPopulationInfected
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TotalPopulationInfected DESC


-- Looking at Countries with Highest Mortality Rate compared to Population
SELECT Location, Population, Max(cast(total_deaths as int)) AS TotalDeathCount, ( Max(cast(total_deaths as int))/Max(population))*100 AS MortalityRate
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TotalDeathCount DESC

-- Looking at Continents with Highest Mortality Rate compared to Population
SELECT continent, Max(cast(total_deaths as int)) AS TotalDeathCount, ( Max(cast(total_deaths as float))/Max(population))*100 AS MortalityRate
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT date, Sum(new_cases) as TotalCasesPerDay, Sum(cast(new_deaths as int)) as TotalDeathsPerDay, Sum(cast(new_deaths as int))/Nullif(Sum(new_cases),0)*100--,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

--USE CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is NOT Null
)
Select * , (RollingPeopleVaccinated/population)*100 as PercentageOfPopulationVaccinated
FROM PopVsVac

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is NOT Null