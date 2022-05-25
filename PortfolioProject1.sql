

/*
Exploration of Covid 19 data 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProyect..[COV-DEATH]
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProyect..[COV-DEATH]
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in any given country

Select Location, date, total_cases, total_deaths, 
CAST(ROUND(cast(Total_deaths as float)/cast(total_cases as float) *100,3) as nvarchar(100)) + '%' as DeathPercentage
From PortfolioProyect..[COV-DEATH]
Where location like '%Ecuador%'
and continent is not null 



-- Total Cases vs Population
-- Shows what percentage of the population has been infected with Covid

Select Location, date, Population, total_cases, 
CAST(ROUND(cast(Total_cases as float)/cast(population as float) *100,3) as nvarchar(100)) + '%' as PercentPopulationInfected
From PortfolioProyect..[COV-DEATH]
order by 1,2


-- Countries with Highest Infection Rate compared to the Population

Select Location, Population, MAX(cast(Total_cases as float)) as HighestInfectionCount,  
ROUND(Max(cast(Total_cases as float)/cast(population as numeric)) *100,3)  as PercentPopulationInfected
From PortfolioProyect..[COV-DEATH]
Group by Location, Population
order by PercentPopulationInfected desc



-- Countries with Highest Death Count compared to the Population
Select Location, Population, MAX(cast(Total_deaths as float)) as totalDeaths,
ROUND(Max(cast(Total_deaths as float)/cast(population as float)) *100,3) as PercentPopulationDeaths
From PortfolioProyect..[COV-DEATH]
Where continent is not null 
Group by Location, Population
order by PercentPopulationDeaths desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as numeric)) as TotalDeathCount
From PortfolioProyect..[COV-DEATH]
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, 
CAST(ROUND(SUM(cast(new_deaths as float))/SUM(cast(New_Cases as float))*100,3) as nvarchar(100)) + '%' as DeathPercentage
From PortfolioProyect..[COV-DEATH]
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,  dea.Date) as RollingPeopleVaccinated
From PortfolioProyect..[COV-DEATH] dea
Join PortfolioProyect..[COV_VACC] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,  dea.Date) as RollingPeopleVaccinated
From PortfolioProyect..[COV-DEATH] dea
Join PortfolioProyect..[COV_VACC] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, CAST(ROUND((RollingPeopleVaccinated/Population)*100,2) AS nvarchar(100)) + '%' as PercentPopulationVaccinated
From PopvsVac
order by 2,3



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations float,
RollingPeopleVaccinated float
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,  dea.Date) as RollingPeopleVaccinated
From PortfolioProyect..[COV-DEATH] dea
Join PortfolioProyect..[COV_VACC] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, CAST(ROUND((RollingPeopleVaccinated/Population)*100,2) AS nvarchar(100)) + '%' as PercentPopulationVaccinated
From #PercentPopulationVaccinated





-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,  dea.Date) as RollingPeopleVaccinated
From PortfolioProyect..[COV-DEATH] dea
Join PortfolioProyect..[COV_VACC] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Create view ProbabilityOfDeath as
Select Location, date, total_cases, total_deaths, 
CAST(ROUND(cast(Total_deaths as float)/cast(total_cases as float) *100,3) as nvarchar(100)) + '%' as DeathPercentage
From PortfolioProyect..[COV-DEATH]
Where location like '%Ecuador%'
and continent is not null 
