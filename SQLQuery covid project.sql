
select * from CovidDeaths
order by 3,4;

select * from CovidVaccinations
order by 3,4;

select location, date, total_cases,new_cases,total_deaths,population from CovidDeaths
order by 1,2;

--look for total cases vs total deaths and to find % of people death who gets diagnosed

select location,date, total_cases , total_deaths , (total_deaths/total_cases)*100 as deathpercentage from CovidDeaths
where location like '%state%'
order by 1,2;

--look at total cases vs popualation and diagnosedpercentage for india
select location, population,date, (total_cases/population)*100 as diagnosedpercentage from CovidDeaths
--where location like '%indi%'
order by diagnosedpercentage desc

looking at countries with highest diagnosed 
select location,date ,population,max(total_cases) as highestinfectioncount , max((total_cases/population))*100 as diagnosedpercentage from CovidDeaths
group by location,population,date
order by diagnosedpercentage desc;

--countries with highest death counts as population
select location,max(cast(total_deaths as int)) as highestdeathcount , population from CovidDeaths
where continent is not null
group by location,population
order by highestdeathcount desc

--continents with highest death counts
select continent, sum(cast(new_deaths as int)) as hoghestdesathcount from CovidDeaths
where continent is not null
group by continent 
order by hoghestdesathcount desc

--global no.
select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as tota_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100  as deathpercentage from  CovidDeaths
where continent is not null
order by 1,2

--join two tables
select dea.continent, dea.location, dea.date , dea.population , vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated  from CovidDeaths as dea
join CovidVaccinations as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--creating CTE(common table expression)

with popVSvac (continent, location, date, population, new_vaccination, rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date , dea.population , vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated  from CovidDeaths as dea
join CovidVaccinations as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null)
select *, rollingpeoplevaccinated/population*100 as rollingpercentage   from popVSvac

--creating temp table 

create Table #percentpopulationvaccinated
( continent varchar(255),
location varchar(255),
date datetime,
population int,
new_vaccination int,
rollingpeoplevaccinated int )

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date , dea.population , vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated  from CovidDeaths as dea
join CovidVaccinations as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
select *, rollingpeoplevaccinated/population*100 as rollingpercentage   from #percentpopulationvaccinated 


select * from #percentpopulationvaccinated

--creating views
create view global as 
select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as tota_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100  as deathpercentage from  CovidDeaths
where continent is not null
--order by 1,2

create view  percentpopulationvaccinated as
select dea.continent, dea.location, dea.date , dea.population , vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated  from CovidDeaths as dea
join CovidVaccinations as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
