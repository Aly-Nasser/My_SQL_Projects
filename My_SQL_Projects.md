#SQL PROJECT ON CONID ,CASES, DEATH, AND VACINATION

**AHOW ALL DATA THAT WE HAVE IN COVID_DEATHS**
SELECT *
FROM covid_deaths
ORDER BY 3, 4

**SHOW THE ALL DATA THAT WE ARE GOING TO START WITH**
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1, 2

**SELECT THE DATA FOR 22 ARABIAN COUNTRY, ALL THE TIME**
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE location IN ('Algeria' ,'Bahrain','Egypt' ,'Iraq' ,'Jordan' ,'Kuwait' ,'Libya' ,'Oman' ,'Palestine' ,'Qatar' ,'Saudi Arabia','Somalia' ,'Sudan' ,'Syria' ,'Tunisia' ,'United Arab Emirates','Yemen' ,'Comoros','Mauritania' ,'Lebanon','Djibouti' ,'Morocco')

**PRECENTAGE OF TOTAL DEATHS OUT Of TOTAL INFECTED CASES IN THE ARABIAN COUNTRIES TILL 17TH OF JUNE**
SELECT  location , date, total_cases, total_deaths , population,
		CONVERT(VARCHAR ,ROUND((total_deaths/total_cases) *100,2)) + '%' AS Death_Percentage
FROM covid_deaths
WHERE location IN ('Algeria' ,'Bahrain','Egypt' ,'Iraq' ,'Jordan' ,'Kuwait' ,'Libya' ,'Oman' ,'Palestine' ,'Qatar' ,'Saudi Arabia','Somalia' ,'Sudan' ,'Syria' ,'Tunisia' ,'United Arab Emirates','Yemen' ,'Comoros','Mauritania' ,'Lebanon','Djibouti' ,'Morocco') AND date = '2022-06-17 00:00:00.000'

**HOW THE PERCENTAGE OF POPULATION GOT COVID, LAST UPDATE 17TH OF JUNE**
SELECT location , date, population, total_cases, CONCAT(ROUND((total_cases/population) *100,2),'%') AS Precentage
FROM covid_deaths
WHERE location IN ('Algeria', 'Bahrain', 'Egypt', 'Iraq', 'Jordan', 'Kuwait', 'Libya', 'Oman', 'Palestine','Qatar' ,'Saudi Arabia','Somalia' ,'Sudan' ,'Syria' ,'Tunisia' ,'United Arab Emirates','Yemen' ,'Comoros', 'Mauritania' ,'Lebanon','Djibouti' ,'Morocco') AND  date = '2022-06-17 00:00:00.000'

**COUNTRY WITH HIGHIEST INFECTION RATE COMPARED TO POPULATION**
SELECT location, population, MAX(total_cases) AS Highest_Infection_Count , 
		Max(ROUND((total_cases/population) *100,2)) AS Percent_Population_Infected
FROM covid_deaths
--WHERE date = '2022-06-17 00:00:00.000'
GROUP BY location , population
ORDER BY Percent_Population_Infected  DESC


**HIGHIEST NUMBER OF CASES BETWEEN ARABIAN COUNTIES**
SELECT LOCATION , MAX(CONVERT(INT,Total_deaths)) AS MAXIMUM_DEATHS_NUM
FROM covid_deaths
--WHERE date = '2022-06-17 00:00:00.000'
WHERE location IN ('Algeria', 'Bahrain', 'Egypt', 'Iraq', 'Jordan', 'Kuwait', 'Libya', 'Oman', 'Palestine','Qatar' ,'Saudi Arabia','Somalia' ,'Sudan' ,'Syria' ,'Tunisia' ,'United Arab Emirates','Yemen' ,'Comoros', 'Mauritania' ,'Lebanon','Djibouti' ,'Morocco')
GROUP BY LOCATION
ORDER BY MAXIMUM_DEATHS_NUM DESC

**BREAKING THINGS DOWN BY CONTINENTS**
**HIGHIEST NUMBER OF DEATHS BY THE CONTINENT**
SELECT continent , MAX(CONVERT(INT,Total_deaths)) AS HIGHIEST_DEATHS_NUM
FROM covid_deaths
--WHERE date = '2022-06-17 00:00:00.000'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HIGHIEST_DEATHS_NUMDESC

**GLOBAL NUMBERS FOR NEW CASES**
SELECT SUM(new_cases) AS total_caes, SUM(CONVERT(INT , new_deaths )) AS total_deaths ,	
ROUND(SUM(CONVERT(INT , new_deaths ))/SUM(new_cases),4) * 100 AS Death_Precentage
FROM covid_deaths
WHERE  continent IS NOT NULL
ORDER BY 1,2

**TOTAL POPULATION VS. VACCINATIONS**
**SHOW PERCENTAGE OF POPULATION THAT HAS RECEIEVED AT LEAST ONE COVID VACCINE**
SELECT die.continent, die.location,die.date, die.population, vac.new_vaccinations,
		SUM(CAST( vac.new_vaccinations AS BIGINT ))
		OVER (PARTITION BY die.location ORDER BY die.location, die.date) AS RollingPeopleVaccinated
FROM covid_deaths die
JOIN covid_vacci vac
		ON die.location = vac.location
		AND die.date = vac.date
WHERE die.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3;

**USING CTE TO PREFORM CALCULATION ON PARTITION BY IN PREVIOS QUERY**
WITH popvsvac(continent, location , date, population,new_vaccinations, RollingPeopleVaccinated) AS
(SELECT  die.continent, die.location , die.date , die.population , vac.new_vaccinations , SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY die.location ORDER BY die.location , die.date) AS RollingPeopleVaccinated
FROM covid_deaths die
JOIN covid_vacci vac 
		ON die.location = vac.location
		AND die.date = vac.date
WHERE die.continent IS NOT NULL AND new_vaccinations IS NOT NULL)
SELECT * , ROUND((RollingPeopleVaccinated/population),4) *100 AS 'Vac_Percentage'
from popvsvac
