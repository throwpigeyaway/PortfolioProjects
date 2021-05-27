Select *
From PortfolioProject..coviddeaths$
Where continent is not null
Order by 3, 4
--Select *
--From PortfolioProject..covidvax$
--Order by 3, 4

-- Select Data
Select Location, date, total_cases, total_deaths, population
From PortfolioProject..coviddeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths ( death %)
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..coviddeaths$
Where location like '%states%'
order by 1,2

-- Looking at total cases vs population (pop gotten covid)
Select Location, date, total_cases,Population, (total_cases/population)*100 as PercPopInfected
From PortfolioProject..coviddeaths$
Where location like '%states%'
order by 1,2

-- Looking at countries with highest Infection rates
Select Location, Max(total_cases) as HighestInfectionCount, Population, Max((total_cases/population))*100 as PerPopInfected
From PortfolioProject..coviddeaths$
--Where location like '%states%'
Group by Location, population
order by PerPopInfected desc



-- Showing countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths$
Where continent is not null
--Where location like '%states%'
Group by Location
order by TotalDeathCount desc

-- By continent
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths$
Where continent is null
--Where location like '%states%'
Group by location
order by TotalDeathCount desc

-- Showing continent with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths$
Where continent is not null
--Where location like '%states%'
Group by continent
order by TotalDeathCount desc

-- Global Numbers
Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as INT)) as total_deaths, (Sum(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..coviddeaths$
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2


-- CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as (
-- Looking at Total Population vs Vaccination 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvax$ vac
	On dea.location = vac.location
	and Dea.date = vac.date
Where dea.continent is not null
--order by 2 ,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Looking at Total Population vs Vaccination w/ temptable
DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvax$ vac
	On dea.location = vac.location
	and Dea.date = vac.date
Where dea.continent is not null
order by 2 ,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated

-- Creating View to store data for later visualization
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvax$ vac
	On dea.location = vac.location
	and Dea.date = vac.date
Where dea.continent is not null
--order by 2 ,3

Select *
From PercentPopulationVaccinated