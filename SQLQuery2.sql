Select * 
from PortfolioProject1..CovidDeaths$
where continent is not null
order by 3,4

--Select * 
--from PortfolioProject1..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract COVID-19 in your country


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject1..CovidDeaths$
WHERE location like '%states'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population contracted COVID-19
Select location, date, population, total_cases, (total_cases/total_deaths)*100 AS DeathPercentage
From PortfolioProject1..CovidDeaths$
--WHERE location like '%states'
order by 1,2

--Looking for countries with the highest infection rate compared to population

Select location, population, MAX(total_cases) AS HighestInfectionCount, (max(total_cases/population))*100 AS InfectedPopPercentage
From PortfolioProject1..CovidDeaths$
--WHERE location like '%states'
group by location, population
order by InfectedPopPercentage desc


--Breaking things down by continent

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
--WHERE location like '%states'
where continent is not null
group by continent
order by TotalDeathCount desc


--This shows countries with the highest death count compared to population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
--WHERE location like '%states'
where continent is not null
group by location
order by TotalDeathCount desc

--This is showing the continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
--WHERE location like '%states'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers

Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths$
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at the total population vs vaccinations

--Use CTE

With PopVsVac (Continent, location, date, population, new_vaccinations, Rollingpplvaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPplVaccinated
--, (RollingPplVaccinated/population)*100
from PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
Select *, (Rollingpplvaccinated/population)*100
FROM popvsvac




--Temp Table

DROP Table if exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpplvaccinated numeric
)

Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPplVaccinated
--, (RollingPplVaccinated/population)*100
from PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select *, (Rollingpplvaccinated/population)*100
FROM #PercentPopVaccinated


--Creating view to store data for later visualizations

Create VIEW PercentPopVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPplVaccinated
--, (RollingPplVaccinated/population)*100
from PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select *
FROM PercentPopVaccinated