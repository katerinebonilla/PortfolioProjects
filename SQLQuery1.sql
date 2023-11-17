Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

--Select Data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likilhood of you dying in the States daily 
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at The Total Cases vs Population 
--Shows what percentage of the population got covid
Select location,date,total_cases,population, (CONVERT(float,total_cases)/population)*100 as TotalCasesPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2 

--Looking at What country has the highest infested population 
Select location,MAX(total_cases) as HighestInfectionCount,population, Max((CONVERT(float,total_cases)/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location,Population 
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count
	Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by location
	order by TotalDeathCount desc
--Showing Highest Death Count based on Continent 
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by continent
	order by TotalDeathCount desc

--Global Numbers
SELECT date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
    CASE WHEN SUM(new_cases) = 0 THEN NULL
         ELSE SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0) * 100
    END as DeathPercentage
FROM  PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

---Total Cases and deaths 
SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
    CASE WHEN SUM(new_cases) = 0 THEN NULL
         ELSE SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0) * 100
    END as DeathPercentage
FROM  PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

Select * 
From PortfolioProject..CovidVaccinations
--Total Population vs Vaccinations
Select death.continent,death.location,death.date,death.population,vac.new_vaccinations
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
On death.location = vac.location
and death.date=vac.date
where death.continent is not null
order by 2,3
--USE CTE 
With PopVsVac (Continent, Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated) 
as ( 
Select death.continent,death.location,death.date,death.population,vac.new_vaccinations,SUM(CONVERT(BIGint,vac.new_vaccinations)) OVER (Partition by death.location Order by death.location,death.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
On death.location = vac.location
and death.date=vac.date
where death.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac
--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric) 

Insert into #PercentPopulationVaccinated
Select death.continent,death.location,death.date,death.population,vac.new_vaccinations,SUM(CONVERT(BIGint,vac.new_vaccinations)) OVER (Partition by death.location Order by death.location,death.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
On death.location = vac.location
and death.date=vac.date
--where death.continent is not null
--order by 2,3
Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select death.continent,death.location,death.date,death.population,vac.new_vaccinations,SUM(CONVERT(BIGint,vac.new_vaccinations)) OVER (Partition by death.location Order by death.location,death.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
On death.location = vac.location
and death.date=vac.date
where death.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated