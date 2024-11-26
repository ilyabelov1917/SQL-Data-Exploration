-- Select data we will be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths cd
ORDER BY 1, 2;

-- Looking at Total Cases VS Total Deaths

SELECT SUM(total_cases) as Total_Cases , SUM(total_deaths) as Total_Deaths, 
ROUND((SUM(total_deaths) / SUM(total_cases)) * 100, 2) as Percentage
FROM CovidDeaths cd
ORDER BY SUM(total_cases) DESC;

--Looking at Total Cases VS Population 

SELECT total_cases, date, location, population, 
ROUND((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100, 3)AS CasesPercentage
FROM CovidDeaths cd
ORDER BY CasesPercentage DESC;

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfection,
ROUND((CAST(MAX(total_cases) AS FLOAT) / CAST(population AS FLOAT)) * 100, 3) AS InfectionRate
FROM CovidDeaths cd
GROUP BY location, population
ORDER BY InfectionRate DESC;


-- Showing Countries with Highest Death Count per Population & Continent
SELECT continent, location, MAX(CAST(total_deaths AS FLOAT)) AS HighestDeath
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY HighestDeath DESC;


---Joining the two tables 
SELECT * 
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location AND cd.date = cv.date; 

---Looking at total population VS vaccinations 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(ISNULL(TRY_CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY cd.continent, cd.location; 


-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(ISNULL(TRY_CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL  

)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(ISNULL(TRY_CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(ISNULL(TRY_CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;



