Select *
From PortoFolioProject..CovidDeaths
WHERE continent is not NULL
order by 3,4

-- Selecting Data that we are to be using 


Select location , date ,total_cases, new_cases , total_deaths , population
From PortoFolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs Total Deaths 


--likelihood of %of diying if you catch covid in congo o

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortoFolioProject..CovidDeaths
Where location like '%congo%'

order by 1,2

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortoFolioProject..CovidDeaths
Where location like '%nigeria%'
order by 1,2


-- Looking at Total cases vs Population 

Select location ,date, total_cases, population, (total_cases/ population) *100 as CovidPopulation_Poourcentage
From PortoFolioProject..CovidDeaths 
where location like '% congo%' AND total_cases is not NULL
order by 1,2

--looking at country with hightest infection rate compared to the population

Select location , MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 as PercentPopulationInfected
From PortoFolioProject..CovidDeaths 
GROUP by location, population
order by PercentPopulationInfected  DESC


--showing the contry with the highest Death count 

Select location , MAX (CAST(total_deaths as int)) as TotalDeathsCount
From PortoFolioProject..CovidDeaths 
WHERE continent is not NULL 
GROUP by location
order by TotalDeathsCount DESC

--LET MAKE IT THINGS MAKE CONTINENT 


Select location , MAX (CAST(total_deaths as int)) as TotalDeathsCount
From PortoFolioProject..CovidDeaths 
WHERE continent is NULL 
GROUP by location
order by TotalDeathsCount desc


-- SHOWING CONTINENT WITH THE HIGHEST DESTH COUNT PER POPULATION 

Select location , MAX (CAST(total_deaths as int)) as TotalDeathsCount
From PortoFolioProject..CovidDeaths 
WHERE continent is NULL 
GROUP by location
order by TotalDeathsCount desc

--GLOBAL NUMBER

Select SUM(new_cases) as total_cases ,
SUM(CAST(new_deaths as int )) as total_deaths, SUM(CAST(new_deaths as int )) / SUM (New_Cases)* 100 as DeathPourcentange 
FROM PortoFolioProject..CovidDeaths

Where continent is not null
--GROUP by date
order by 1,2


select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as ROllingpeoplvaccinted 


FROM PortoFolioProject..CovidDeaths dea
JOIN PortoFolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not NULL
 ORDER by 2,3
 
 -- USING A CTE 
 

 WITH PopvsVac ( Continent , Location , Date , Population , New_Vaccinations ,ROllingpeoplvaccinted)
 
 as

 (


select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location ,dea.Date ) as ROllingpeoplvaccinted 



From PortoFolioProject..CovidDeaths dea
JOIN PortoFolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not NULL
 ORDER by 2,3 )
 
 select *
 from PopvsVac



 -- USING TEMP 


 DROP TABLE IF EXISTS #PercentPopulationVaccinated
 create Table #PercentPopulationVaccinated
 (Continent nvarchar(225),
 Location nvarchar(225),
 Date datetime,
 Population numeric ,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric)


 insert into #PercentPopulationVaccinated


SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS numeric))  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
    PortoFolioProject..CovidDeaths dea
JOIN
    PortoFolioProject..CovidVaccinations vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    2, 3;

 
 SELECT
    *,
    CAST((RollingPeopleVaccinated / population) * 100 AS numeric) AS PercentPopulationVaccinated
FROM
    #PercentPopulationVaccinated;





  select *, (RollingPeopleVaccinated / population) *100
 from #PercentPopulationVaccinated



 --CREATING A VIEW TO STORE DATA LATER VISUALISATION 

 Create View percentPopulationVaccinated as
 

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS numeric))  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
    PortoFolioProject..CovidDeaths dea
JOIN
    PortoFolioProject..CovidVaccinations vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
--ORDER BY 2, 3;

select * 
from percentPopulationVaccinated