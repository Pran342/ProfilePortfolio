Select *
From ProfilePortfolio..CovidDeath
Where continent is not null
order by 3,4

Select *
From ProfilePortfolio..[dbo.CovidVaccination]
Where continent is not null
order by 3,4


Select location, date, total_cases, total_deaths, population
From ProfilePortfolio..CovidDeath
Where continent is not null
order by 1,2

alter table dbo.CovidDeath
alter column total_deaths INTEGER;

alter table dbo.CovidDeath
alter column total_cases INTEGER;

--looking at total cases vs total deaths
--Shows likehood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as Death_Percantage
From ProfilePortfolio..CovidDeath
Where continent is not null
--Where location like '%Nepal%'
order by 1,2	

--looking at total cases vs population
--shows what percentage got covid

Select location, date, total_cases, population, (cast(total_cases as float)/population)*100 as Covid_Percantage
From ProfilePortfolio..CovidDeath
Where continent is not null
--Where location like '%Australia%'
order by 1,2

--Looking at countries with highest infection rate
Select location, MAX(total_cases)as HighestInfectionCount, population, MAX(cast(total_cases as float)/population)*100 as Infected_Percent
From ProfilePortfolio..CovidDeath
Where continent is not null
--Where location like '%Australia%'
group by location, population
order by Infected_Percent desc

--Showing countries with highest death count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProfilePortfolio..CovidDeath
Where continent is not null
group by location
order by TotalDeathCount desc

--Dividing by Continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProfilePortfolio..CovidDeath
Where continent is not null
group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProfilePortfolio..CovidDeath
Where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercantage
From ProfilePortfolio..CovidDeath
--Where location like '%Nepal%'
Where continent is not null
--Group by date
order by 1,2

--looking at toatal population vs vaccination
--Use CTE

with PopvsVac(continenet, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From ProfilePortfolio..CovidDeath dea
Join ProfilePortfolio..CovidVaccination vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--where dea.location like '%Australia%'
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100 as Vaccinated
From PopvsVac


--Temp Table 
Drop table if exists #PercentPopulationVaccinate
Create Table #PercentPopulationVaccinate
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into #PercentPopulationVaccinate
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, isnull(vac.new_vaccinations,0))) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From ProfilePortfolio..CovidDeath dea
Join ProfilePortfolio..CovidVaccination vac
     On dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--where dea.location like '%Australia%'
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as Vaccinated
From #PercentPopulationVaccinate

--Creating view for for store data later

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, isnull(vac.new_vaccinations,0))) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From ProfilePortfolio..CovidDeath dea
Join ProfilePortfolio..CovidVaccination vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--where dea.location like '%Australia%'
--order by 2,3
Select * 
From PercentPopulationVaccinated