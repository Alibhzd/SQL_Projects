
-- check databases
Select *
From PortfolioProject..CovidDeaths
order by 3,4

Select *
From CovidVaccinations
Order by 3,4 


-- Select data

Select Location, date, population, total_cases, new_cases, total_deaths
from CovidDeaths
order by 1,2

-- Total cases vs. total deaths in Germany over 3 years
Select Location, date, cast(total_cases as float) as total_cases, cast(total_deaths as float) as total_deaths,
	new_deaths, (cast(total_deaths as float)/ nullif(cast(total_cases as float), 0))*100 as DeathPercentage
	--the above code only change the data type to float so that it runs with the 'null' cells in both columns.
from CovidDeaths
where total_cases IS NOT NULL AND total_deaths IS NOT NULL and location = 'Germany'
--this removes the 'null' cells from the table.
order by 1,2



-- What percentage of population got COVID over time?
-- Total cases vs, population
Select Location, date, population, cast(total_cases as float) as total_cases,
	(nullif(cast(total_cases as float), 0)/population)*100 PopPercentageInfected
from CovidDeaths
where total_cases IS NOT NULL
--this removes the 'null' cells from the table.
order by 1,2
 

-- Highest infection rate vs. population
Select location, population, MAX(cast(total_cases as float)) as HighestInfectionCount, 
	(nullif(MAX(cast(total_cases as float)), 0)/population)*100 PopPercentageInfected
from CovidDeaths
group by location, Population
order by PopPercentageInfected desc


-- Countries with highest death rate per population
Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



-- Total death per continent
Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


 -- Global numbers
 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, 
	(nullif(SUM(cast(new_deaths as float)), 0)/SUM(new_cases)*100) as DeathPercentage
 from CovidDeaths 
 where continent is not null
 order by 1,2


 ----------- COVID Vaccinations dataset
 Select *
 from CovidVaccinations	




 -- joining two datasets

 Select *
 From CovidDeaths as death
 join CovidVaccinations as Vax
	on death.location = vax.location
	and death.date = vax.date


-- What is the total number of people in the world who have been vaccinated?
-- Total population vs. total Vaccination

----- Use CTE

With PopvsVax (Continent, location, date, population, NewVaxed, SumPplVaxed)
as
(
 Select death.continent, death.location, death.date, death.population, vax.new_vaccinations as NewVaxed,
 Sum(convert(bigint, vax.new_vaccinations)) over (partition by death.location order by death.location,
 death.date) as SumPplVaxed-- used 'bigint' above since the sum value was too large
 From CovidDeaths as death
 join CovidVaccinations as Vax
	on death.location = vax.location
	and death.date = vax.date
where death.continent is not null
--order by 2,3
)
Select *, (SumPplVaxed/population)*100 as TotalPplVaxed
From PopvsVax


----- Temp Table

Drop table if exists #PercentagePopVaxed
Create table #PercentagePopVaxed
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
NewVaxed numeric,
SumPplVaxed numeric
)
Insert into #PercentagePopVaxed
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations as NewVaxed,
 Sum(convert(bigint, vax.new_vaccinations)) over (partition by death.location order by death.location,
 death.date) as SumPplVaxed-- used 'bigint' above since the sum value was too large
 From CovidDeaths as death
 join CovidVaccinations as Vax
	on death.location = vax.location
	and death.date = vax.date
where death.continent is not null


Select *, (SumPplVaxed/population)*100 as PercentagePplVaxed
From #PercentagePopVaxed

---- NOTE:
--number of vaccine doses administered per 100 people within a given population. 
-- it’s important to bear in mind that in some territories, vaccination coverage may
--include non-residents (such as tourists and foreign workers).For these reasons, 
--per-capita metrics may sometimes exceed 100%.
--Total COVID-19 vaccine doses administered per 100 people, May 6, 2023
--All doses, including boosters, are counted individually.


-- Create View to store data for later visualizations

Create view PercentagePopVaxed as
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations as NewVaxed,
 Sum(convert(bigint, vax.new_vaccinations)) over (partition by death.location order by death.location,
 death.date) as SumPplVaxed
 From CovidDeaths as death
 join CovidVaccinations as Vax
	on death.location = vax.location
	and death.date = vax.date
where death.continent is not null



