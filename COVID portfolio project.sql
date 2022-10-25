-- The data
SELECT *
FROM portfolioproject..coviddeaths
WHERE continent IS NOT NULL;

--Change datatype of different columns

ALTER TABLE portfolioproject..coviddeaths
ALTER COLUMN total_deaths float;

ALTER TABLE portfolioproject..coviddeaths
ALTER COLUMN new_deaths float;

ALTER TABLE portfolioproject..covidvaccinations
ALTER COLUMN new_tests float;

ALTER TABLE portfolioproject..covidvaccinations
ALTER COLUMN total_tests float;

ALTER TABLE portfolioproject..covidvaccinations
ALTER COLUMN total_vaccinations float;

ALTER TABLE portfolioproject..covidvaccinations
ALTER COLUMN new_vaccinations float;


-- Select the data that will be used from covid deaths

SELECT Location, 
	   date, 
       total_cases, 
       new_cases,
       total_deaths,
       population
FROM portfolioproject..coviddeaths
WHERE continent IS NOT NULL
order by 1,2;

-- Looking at the death per cases percentage
SELECT Location, 
	   date, 
       total_cases, 
       new_cases,
       total_deaths,
       (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolioproject..coviddeaths
WHERE continent IS NOT NULL
order by 1,2;

-- Getting the data for Nigeria ordered by dates
-- Shows likelihood of dying from covid on that day
SELECT Location, 
	   date, 
       total_cases, 
       new_cases,
       total_deaths,
       (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolioproject..coviddeaths
WHERE continent IS NOT NULL AND 
      Location LIKE 'Nigeria'
order by 2;

-- Total cases vs population
-- Shows the likelihood of contracting covid
-- Shows the percentage of the population that got covid in Nigeria in that day
SELECT Location, 
	   date, 
       total_cases, 
       population,
       total_deaths,
       (total_cases/population)*100 AS CasePercentage
FROM portfolioproject..coviddeaths
WHERE location LIKE 'Nigeria' AND
      continent IS NOT NULL
order by 6 desc;

-- Order the locations by the total amount of deaths recorded in each country
SELECT Location,
	   max(total_deaths) AS Total_deaths
from portfolioproject..coviddeaths
WHERE continent IS NOT NULL
group by Location
order by 2 DESC;

--Order the locations by the total number of cases recordedd in each country in desc order
SELECT Location,
	   max(total_cases) AS Total_cases
from portfolioproject..coviddeaths
WHERE continent IS NOT NULL
group by Location
order by 2 DESC;


-- What location has the highest infection rate compared to population?
SELECT Location, 
       population,
       max(total_cases) AS HighestInfectionCount,
       max(total_cases/population)*100 AS PercentPopulationInfected
FROM portfolioproject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
order by 3 DESC;


-- Showing countries with highest Death Count per population
-- Order by percent of population that died
SELECT Location, 
       population,
       max(total_deaths) AS HighestDeathCount,
       max(total_deaths/population)*100 AS PercentPopulationDied
FROM portfolioproject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
order by 4 DESC;

-- ANALYZING BY CONTINENT
-- COntinents with the highest death count
-- Order by highest death count
SELECT Location,
	   population,
       max(total_deaths) AS HighestDeathCount
FROM portfolioproject..coviddeaths
WHERE continent IS NULL AND
      location NOT IN ('World', 'International')
GROUP BY Location, population
ORDER BY 3 DESC;



-- African countries with the highest death count
-- Order by total number of deaths
SELECT Location,
       population,
       max(total_deaths) AS HighestDeathCount
FROM portfolioproject..coviddeaths
WHERE continent LIKE 'Africa'
GROUP BY Location, population
ORDER BY 3 DESC;

-- GLOBAL NUMBERS
-- Total cases, total deaths, Death Percentage daily globally
-- Order by the death percentage
-- Shows the days where we had the highest death to case percentage
SELECT date, 
       SUM(new_cases) AS total_casees,
       SUM(new_deaths) AS total_deaths,
       SUM(new_deaths)/SUM(new_cases) AS DeathPercentage
FROM portfolioproject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
order by 4 desc;

-- Total number of deaths, cases and death percentage during the whole period
SELECT SUM(new_cases) AS total_casees,
       SUM(new_deaths) AS total_deaths,
       SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM portfolioproject..coviddeaths
WHERE continent IS NOT NULL
order by 1,2;


-- Join the covid deaths and vaccination tables on the location and deaths column
SELECT *
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vacs
	ON dea.location = vacs.location AND
	   dea.date = vacs.date;
       
-- Total populations vs vaccinations
SELECT dea.continent,
	   dea.location,
       dea.date,
       dea.population,
       vacs.new_vaccinations,
       SUM(vacs.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
       dea.date) AS PeopleVaccinated
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vacs
	ON dea.location = vacs.location AND
	   dea.date = vacs.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated) AS
(
SELECT dea.continent,
	   dea.location,
       dea.date,
       dea.population,
       vacs.new_vaccinations,
       SUM(vacs.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
       dea.date) AS PeopleVaccinated
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vacs
	ON dea.location = vacs.location AND
	   dea.date = vacs.date
WHERE dea.continent IS NOT NULL
)

Select *, (PeopleVaccinated/Population)*100 AS PercentPopVaccinated
FROM PopvsVac;


-- Create a view 
CREATE VIEW PercentagePopVac AS
SELECT dea.continent,
	   dea.location,
       dea.date,
       dea.population,
       vacs.new_vaccinations,
       SUM(vacs.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
       dea.date) AS PeopleVaccinated
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vacs
	ON dea.location = vacs.location AND
	   dea.date = vacs.date
WHERE dea.continent IS NOT NULL;

-- In Nigeria, the number of people that were vaccinated
SELECT dea.location,
       dea.date,
	   dea.population,
	   vacs.new_vaccinations,
	   SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
	   dea.date) AS PeopleVacNig
FROM portfolioproject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vacs
	ON dea.location = vacs.location AND
	   dea.date = vacs.date
WHERE dea.location LIKE 'Nigeria';

-- When did vaccinations begin in Nigeria
SELECT TOP 1 dea.location,
       dea.date,
	   dea.population,
	   vacs.new_vaccinations,
	   SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
	   dea.date) AS PeopleVacNig
FROM portfolioproject..coviddeaths dea 
JOIN PortfolioProject..covidvaccinations vacs
	ON dea.location = vacs.location AND
	   dea.date = vacs.date
WHERE dea.location LIKE 'Nigeria' AND
      vacs.new_vaccinations IS NOT NULL

-- Which african country has the highest vaccination rate?

SELECT dea.location,
	   max(vacs.total_vaccinations)/dea.population AS PeopleVacNig
FROM portfolioproject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vacs
	ON dea.location = vacs.location AND
	   dea.date = vacs.date
WHERE dea.continent LIKE 'Africa'
GROUP BY dea.location, dea.population;