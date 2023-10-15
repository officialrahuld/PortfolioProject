Select* 
From PortfolioProject..CovidDeaths
order by 3,4

--Select* 
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths	
order by 1,2

-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country (US)

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths	
where location like '%states%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid

Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths	
where location like '%states%'
order by 1,2

-- Looking at countries with the highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths	
--where location like '%states%'
group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population

Select Location, MAX(cast(total_cases as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths	
--where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc

-- Let's break things down by continent
-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_cases as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths	
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers

Select Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, Sum(new_deaths)/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths	
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



------------------------------------------


-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3


-- Use CTE

with PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualisation

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated
