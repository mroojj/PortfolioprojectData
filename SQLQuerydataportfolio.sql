Select*
From Portfolioproject..CovidDead
Where Continent is not null
Order by 3,4
--Select*
--From Portfolioproject..Covidvaccination
--Order by 3,4

--select Data that we are going to be using

Select location, date, total_cases
 From Portfolioproject..CovidDead
 Where Continent is not null
 Order by 1,2


 --Looking at Total cases vs Total Deaths
 --Shows Likelihood of dying if you contract covid in your country

 Select location, date,total_cases,total_deaths, (total_Deaths/total_cases)*100 as Deathpercentage
 From Portfolioproject..CovidDead
 Where location like '%Vietnam%'
 and Continent is not null
 Order by 1,2

 -- Looking at Total Cases vs Population
 --Shows what percentage of population got covid

 Select location, date,total_cases,total_deaths,Population, (Total_cases/Population)*100 as PercentPopulationInfected
 From Portfolioproject..CovidDead
 Where location like '%Vietnam%'
 Order by 1,2 


 --Looking at countries with Highest Infection Rate Compared To Population 

 Select location, Population, MAX(Total_cases) as HighestInfectionCount, MAX(Total_cases/Population)*100 as PercentPopulationInfected
 From Portfolioproject..CovidDead
 --Where location like '%Vietnam%'
 Group by Location, Population
 Order by PercentPopulationInfected desc


 -- Showing Country with highest death Count Per Poplulation

 Select location, MAX(cast (total_deaths as int))  as TotalDeathCount
 From Portfolioproject..CovidDead
 --Where location like '%Vietnam%'
 Where Continent is not null
 Group by Location
 Order by TotalDeathCount desc


 --LET'S BREAK THINGS DOWN BY CONTINENT



 
 -- Showing the continent with the highest death count per population


 Select continent, MAX(cast (total_deaths as int))  as TotalDeathCount
 From Portfolioproject..CovidDead
 --Where location like '%Vietnam%'
 Where Continent is not null
 Group by continent
 Order by TotalDeathCount desc



--GlOBAL NUMBER


 Select SUM(new_cases) as total_cases, SUM(cast(new_Deaths as int)) as total_deaths, SUM(cast(new_Deaths as int))/SUM(new_cases)*100 as Deathpercentage
 From Portfolioproject..CovidDead
 --Where location like '%Vietnam%'
 Where  Continent is not null
 --Group By date
 Order by 1,2



 --Looking at Total Population vs Vaccinations

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   , SUM(CONVERT( bigint, vac.new_vaccinations)) OVER ( Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated,
   --, (RollingPeopleVaccinated/population)*100
  From Portfolioproject..CovidDead dea
  join Portfolioproject..Covidvaccination vac
             on dea.location = vac.location
             and dea.date = vac.date
Where dea.continent is not  null
Order by 2,3



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDead dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE

with Popvsvac ( continent, location, date, population,new_vaccinations, rollingpeoplevaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDead dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (rollingpeoplevaccinated/population)*100
from Popvsvac

--  TEMP TABLE


DROP Table if exists #PercentpopulationVacinated
Create Table #PercentpopulationVacinated
(
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population Numeric,
 new_vaccinations Numeric,
 RollingPeopleVaccinated Numeric
 )

Insert into #PercentpopulationVacinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDead dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
from #PercentpopulationVacinated


--Creating view to store data for later visualization


Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDead dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



Select*
From PercentPopulationVaccinated