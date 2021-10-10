SELECT location,date,total_cases,new_cases,total_deaths,population
from covid_analysis.dbo.covid_deaths$ 
order by 4;
SELECT location,convert(float ,total_deaths),convert(float,total_cases)
from covid_analysis.dbo.covid_deaths$
--loking at totla cases vs total deaths
SELECT location,date,total_cases, total_deaths,(total_deaths/ total_cases)*100 as "death%" 
from covid_analysis.dbo.covid_deaths$
where location like '%states%'
order by 3 desc;
--show likelihood of dying if you contarct the covid in your contry
SELECT location,sum(convert(int,total_deaths)),sum(total_cases),(sum(convert(float ,total_deaths)) / sum(total_cases))*100 as "death%" 
from covid_analysis.dbo.covid_deaths$
where (total_deaths / total_cases)*100 is not NULL
--and location like '%states%'
group by location
order by 1;
--locking at tolat cases vs population
--show what percentage of population got covid 
SELECT location,date,total_cases, population ,( total_cases/population)*100 as "cases%" 
from covid_analysis.dbo.covid_deaths$
order by 1,3 desc;
SELECT location,date,total_cases, population ,( total_cases/population)*100 as "cases%" 
from covid_analysis.dbo.covid_deaths$
where location like '%states%'
order by 1,3 desc;

--show likelihood of dying if you contarct the covid in your contry
SELECT location,sum(population) as "total_population",sum(total_cases) as "total cases",(sum(total_cases)/sum(population))*100 as "cases poucentage"
from covid_analysis.dbo.covid_deaths$
group by location
order by 1;

-- looking at contries with highest infection rate compared to population
SELECT location,population ,max(total_cases) as "highestInfection_count",max( ( total_cases/population))*100 as "highest rates country " 
from covid_analysis.dbo.covid_deaths$
group by location ,population
order by 3 desc;
--let's break things down by continent
SELECT location,max(cast(total_deaths as int)) as total_deathcount
from covid_analysis.dbo.covid_deaths$
where continent is  null
group by location
order by total_deathcount desc;
SELECT continent,max(cast(total_deaths as int)) as total_deathcount
from covid_analysis.dbo.covid_deaths$
where continent is  not null
group by continent 
order by total_deathcount desc;
--shiwing countries with highest death count per population
SELECT   location,population,max(cast(total_deaths as int)) as total_deathcount
from covid_analysis.dbo.covid_deaths$
where continent is not null
group by location,population
order by 2 desc;

--showing the countinent with  the highest death count per population
SELECT continent,max(cast(total_deaths as int)) as total_deathcount
from covid_analysis.dbo.covid_deaths$
where continent is not null
group by continent
order by total_deathcount desc;


-- Global numbers
SELECT sum(new_cases) as total_new_cases,sum(cast(new_deaths as int )) as new_deaths, (sum(cast(new_deaths as int))/ sum(new_cases))*100 as new_deaths_percentage
from covid_analysis.dbo.covid_deaths$
where continent is not null 
--group by date
order by date;
--Looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date)
as Rolling_people_vaccinated--(Rolling_people_vaccinated/population)*100
from covid_analysis..covid_deaths$ dea 
join covid_analysis..covid_vaccinations$ vac
on vac.location=dea.location  and vac.date=dea.date 
where dea.continent is not null 
order by 2,3 

-- use CTE
with PopvcVac(continent,location,date,population, new_vaccinations,Rolling_people_vaccinated)
as
(
select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date)
as Rolling_people_vaccinated
from covid_analysis..covid_deaths$ dea 
join covid_analysis..covid_vaccinations$ vac
on vac.location=dea.location  and vac.date=dea.date 
where dea.continent is not null 
)
select * ,(Rolling_people_vaccinated/population)*100
from PopvcVac
--Temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar (255),
location nvarchar(255),
date datetime ,
population numeric,
new_vaccination numeric,
Rolling_people_vaccinated numeric)

insert into #percentpopulationvaccinated 
select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date)
as Rolling_people_vaccinated
from covid_analysis..covid_deaths$ dea 
join covid_analysis..covid_vaccinations$ vac
on vac.location=dea.location  and vac.date=dea.date 
where dea.continent is not null 
select* from #percentpopulationvaccinated
-- creating view to store data for later visualization
create view  percentpopulationvaccinated as 
select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date)
as Rolling_people_vaccinated
from covid_analysis..covid_deaths$ dea 
join covid_analysis..covid_vaccinations$ vac
on vac.location=dea.location  and vac.date=dea.date 
where dea.continent is not null
