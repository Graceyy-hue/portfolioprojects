

Select *
from PortfolioProject..[Covid deaths]
where continent is not null
order by 3,4

Select *
from PortfolioProject..Covidvacc
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..[Covid deaths]
order by 1,2

-- Looking at total cases vs total deaths
-- looking at the probability of dying from covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[Covid deaths]
where location like '%Nigeria%'
order by 1,2

-- Looking at total cases vs population
-- shows the percentage of the population with covid

select location, date, total_cases , population, (total_cases/population)*100 as popPercentage
from PortfolioProject..[Covid deaths]
where location like '%Nigeria%'
order by 1,2

--Looking at highest infection rate compared to population
select location, population, MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as percentagepopulationinfected
from PortfolioProject..[Covid deaths]
--where location like '%Nigeria%'
GROUP BY location, population
order by percentagepopulationinfected desc

--showing countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..[Covid deaths]
--where location like '%Nigeria%'
where continent is not null
GROUP BY location
order by Totaldeathcount desc

--Breaking down by continent
--showing continents with the highest deaths per population
select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..[Covid deaths]
--where location like '%Nigeria%'
where continent is not null
GROUP BY continent
order by Totaldeathcount desc


--Global numbers
select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from PortfolioProject..[Covid deaths]
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2

-- looking a total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as Rollingpeoplevacc
from PortfolioProject..[Covid deaths] dea
join PortfolioProject..Covidvacc  vacc
     on dea.location = vacc.location
	 and dea.date = vacc.date
where dea.continent is not null
order by 2,3 



--Use CTE
with popvsvacc (continent, location, date, population,new_vaccinations, Rollingpeoplevacc)
as
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as Rollingpeoplevacc
from PortfolioProject..[Covid deaths] dea
join PortfolioProject..Covidvacc  vacc
     on dea.location = vacc.location
	 and dea.date = vacc.date
where dea.continent is not null
--order by 2,3 
)
select *, (Rollingpeoplevacc/population) * 100
from popvsvacc

--Temp table
DROP Table #Percentpopulationvaccinated
create table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevacc numeric
)

insert into #Percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as Rollingpeoplevacc
from PortfolioProject..[Covid deaths] dea
join PortfolioProject..Covidvacc  vacc
     on dea.location = vacc.location
	 and dea.date = vacc.date
where dea.continent is not null
--order by 2,3 

select *, (Rollingpeoplevacc/population) * 100
from #Percentpopulationvaccinated

-- for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as Rollingpeoplevacc
from PortfolioProject..[Covid deaths] dea
join PortfolioProject..Covidvacc  vacc
     on dea.location = vacc.location
	 and dea.date = vacc.date
where dea.continent is not null
--order by 2,3 


