
use [Portfolio Project];
select iso_code, max(new_cases) as max_new_cases from Covid_Deaths
group by iso_code
order by max_new_cases asc;

select * from Covid_Deaths;

select location, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, (sum (cast(new_deaths as int))/sum(new_cases)) as Death_Rate 
from Covid_Deaths group by location having (sum (cast(new_deaths as int))/sum(new_cases)) is not null order by (sum (cast(new_deaths as int))/sum(new_cases)) desc;





--LOOKING AT COUNTRY-WISE

        
		--looking at total deaths 
 
        select location, sum(cast(new_deaths as int)) as Total_Deaths from Covid_Deaths 
	    where location not in('World', 'Europe', 'Africa', 'North America', 'European Union','South America','Asia','Oceania','International') 
	    group by location having sum(cast(new_deaths as int)) is not null order by sum(cast(new_deaths as int)) desc;


		select location, sum(cast(new_deaths as int)) as Total_Deaths from Covid_Deaths 
	    where continent is not null 
	    group by location having sum(cast(new_deaths as int)) is not null order by sum(cast(new_deaths as int)) desc;


        select location, max(cast(total_deaths as int)) as Total_Deaths from Covid_Deaths  
		where continent is not null  group by location order by max(cast(total_deaths as int)) desc;

		create view View_Total_Deaths as
		  select location, max(cast(total_deaths as int)) as Total_Deaths from Covid_Deaths  
		where continent is not null   group by location having max(cast(total_deaths as int)) is not null ;
  


        
        --looking at death rates

        select location, max(date) as latest_date ,max(total_cases) as Total_Cases, max(total_deaths) as Total_Deaths,
	    round((max(total_deaths)/max(total_cases)),4) as Death_Rate 
        from Covid_Deaths  where continent is not null  
		group by location having round((max(total_deaths)/max(total_cases)),4)  is not null order by Death_Rate desc;






        --looking at infection rate

        ----using group by clause
        select top 20 location, max(total_cases) as Total_Cases, max(population) as Population, max(total_cases)/max(population) as Infection_Rate 
        from Covid_Deaths  where continent is not null  
		group by location having max(total_cases)/max(population) is not null order by Infection_Rate desc;



        ---- using cte
        with cte as (select location, max(population) as Population, max(total_cases) as Total_Cases, 
		concat(round(max(total_cases)/max(population),5),'%') as Infection_Percentage 
        from Covid_Deaths  where continent is not null  
		group by location having max(total_cases)/max(population) is not null) SELECT * FROM cte;



        ----using ranked window function
        select distinct * from 
        (select location, population, total_cases ,total_cases/population as Infection_Rate, 
		dense_rank() over (partition by location order by (total_cases/population) desc) as rank_ 
        from Covid_Deaths where (total_cases/population) is not null) D
        where rank_=1 order by Infection_Rate desc;


 


        --looking at country-wise deaths per million

        select distinct location, population, total_deaths, (total_deaths/population)*1000000 as Deaths_per_million, rank_ from
        (select location, population, total_deaths, (total_deaths/population)*1000000 as Deaths_per_million , 
		dense_rank() over (partition by location order by (total_deaths/population)  desc) as rank_
        from Covid_Deaths) D where rank_=1 and (total_deaths/population) is not null order by (total_deaths/population)*1000000 desc;


		select location, max(population) as Population, (sum(cast(new_deaths as int))/max(population))*1000000 as Total_Deaths_per_million from Covid_Deaths 
		where continent is not null 
		group by location having (sum(cast(new_deaths as int))/max(population))*1000000 is not null 
		order by (sum(cast(new_deaths as int))/max(population))*1000000 desc;
	





--LOOKING AT CONTINENT-WISE


        --looking at total deaths
 
        --select continent, max(cast(total_deaths as int)) as Total_Deaths from Covid_Deaths where continent is not null group by continent 
		--order by max(cast(total_deaths as int)) desc; (not working correctly)

		select continent, sum(cast(new_deaths as int)) as Total_Deaths from Covid_Deaths where continent is not null group by continent 
		order by sum(cast(new_deaths as int)) desc;

		select location, max(cast(total_deaths as int)) as Total_Deaths from Covid_Deaths where continent is null group by location
		order by  max(cast(total_deaths as int)) desc;





		--looking at death rates
		
		select continent, sum(population) as Population, max(cast(total_deaths as int)) as Total_Deaths, max(total_cases) as Total_Cases, 
		max(cast(total_deaths as int))/max(total_cases) as Death_Rate
		from Covid_Deaths where continent is not null group by continent;





		--looking at Infection_Rate

		select continent, max(total_cases) as Total_Cases, max(population) as Population, max(total_cases)/max(population) as Infection_Rate
		from Covid_Deaths where continent is not null group by continent order by max(total_cases)/max(population) desc;





		--looking at deaths per million

		select continent, max(cast(total_deaths as int)) as Total_Deaths, max(population) as Population, (max(cast(total_deaths as int))/ max(population))*1000000 
		as deaths_per_million from Covid_Deaths where continent is not null group by continent order by (max(cast(total_deaths as int))/ max(population))*1000000  desc;






--LOOKING AT A GLOBAL LEVEL



        --looking at total_deaths

        select (select distinct location from Covid_Deaths where location ='World') as Location, 
		max(cast(total_deaths as int)) as Total_Deaths, max(population) as World_Population
        from Covid_Deaths;

		create view




		--looking at death rates

		select (select distinct location from Covid_Deaths where location ='World') as Location, 
		max(cast(total_deaths as int)) as Total_Deaths, max(total_cases) as Total_Cases,
		max(cast(total_deaths as int))/max(total_cases) as Death_Rate
		from Covid_Deaths;




		--looking at Infection_Rate

		select (select distinct location from Covid_Deaths where location='World') as Location, max(total_cases) as Total_Cases, max(population) as World_Population,
	    max(total_cases)/max(population) as Infection_Rate from Covid_Deaths;


		--2nd method
		select distinct (select distinct location from Covid_Deaths where location='World') as Location, 
		(select sum(cast(new_cases as int)) from Covid_Deaths where continent is not null) as Total_Cases,
		(select sum(distinct population) from Covid_Deaths where continent is not null) as World_Population,
		(select sum(cast(new_cases as int)) from Covid_Deaths where continent is not null)/(select sum(distinct population) from Covid_Deaths where continent is not null) as Infection_Rate
		from Covid_Deaths;





		--looking at deaths per million

		select (select distinct location from Covid_Deaths where location='World') as Location, max(total_cases) as Total_Cases, 
		max(population) as World_Population, (max(total_cases)/max(population))*1000000 as deaths_per_million from Covid_Deaths;
		


		--looking at date-wise

		select date, sum(new_cases) as Cases_per_day, sum(cast(new_deaths as int)) as Deaths_per_day, (sum(cast(new_deaths as int))/sum(new_cases)) as Death_Rate
		from Covid_Deaths where continent is not null
		group by date having sum(cast(new_cases as int)) is not null order by date asc ;
		


		select sum(new_cases) as Cases, sum(cast(new_deaths as int)) as Deaths, (sum(cast(new_deaths as int))/sum(new_cases)) as Death_Rate
		from Covid_Deaths where continent is not null having sum(cast(new_cases as int)) is not null;





--LOOKING AT TOTAL POPULATION VS TESTS

 

        --using CTE

		

		--1
		with pop_vs_test as(
		select cd.location, cd.date, cd.population, cv.new_tests as Tests_per_day, sum(cast(cv.new_tests as int)) over (partition by cd.location order by cd.date) as Cumulative_Tests
		from  Covid_Deaths cd inner join Covid_Vaccinations cv on cd.location=cv.location and cd.date=cv.date where cv.new_tests is not null
		)
		select location, max(date) as Date, max(population) as Population, max(Cumulative_Tests) as Total_Tests, (max(Cumulative_Tests)/max(population)) as Tests_per_Person 
		from pop_vs_test group by location order by location  asc;



		--2
		with pop_vs_test as(
		select cd.location, cd.date, cd.population, cv.new_tests, sum(cast(cv.new_tests as int)) over (partition by cd.location order by cd.date) as Cumulative_Tests, 
		(sum(cast(cv.new_tests as int)) over (partition by cd.location order by cd.date)/cd.population)*100 as Percent_pop_Vaccinated
		from Covid_Deaths cd inner join Covid_Vaccinations cv on cd.location=cv.location and cd.date=cv.date where  cv.new_tests is not null
		)
		select location, max(date) as Date, max(population) as Population, max(Cumulative_Tests) as Total_Tests, max(Percent_pop_Vaccinated) as Percent_pop_Vaccinated from pop_vs_test
		group by location;









		--using Table and creating view


        drop table if exists Tests_per_Person;

		create table Tests_per_Person (
		location nvarchar(255),
		Date datetime,
		Population float,
		Test_per_Day nvarchar(255),
		Cumulative_Tests nvarchar(255));



		insert into Tests_per_Person select * from
		(
		select cd.location, cd.date, cd.population, cast(cv.new_tests as int) as Tests_per_Day, sum(cast(cv.new_tests as int)) over (partition by cd.location order by cd.date) as Cumulative_Tests
		from Covid_Deaths cd inner join Covid_Vaccinations cv on cd.location=cv.location and cd.date=cv.date where cv.new_Tests is not null) D;


		select * from Tests_per_Person;


		select location as Location, max(Date) as Date, max(Population) as Population, Max(cast(Cumulative_Tests as int)) as Total_Tests,  
		Max(cast(Cumulative_Tests as int))/max(Population) as Tests_per_Person
		from Tests_per_Person group by location
		order by location;



		create view View_Tests_per_Person as
		select location as Location, max(Date) as Date, max(Population) as Population, Max(cast(Cumulative_Tests as int)) as Total_Tests,  
		Max(cast(Cumulative_Tests as int))/max(Population) as Tests_per_Person
		from Tests_per_Person group by location;

		select * from View_Tests_per_Person order by location;







		





--LOOKING AT TOTAL POPULATION VS TOTAL VACCINATIONS






        --using temp table


		create table #Percent_Vaccinated (
		location nvarchar(255),
		date datetime,
		population float,
		Daily_Vaccinations nvarchar(255),
		Cumulative_Vaccinations float,
		Pop_Percent_Vaccinated float
		)


		insert into #Percent_Vaccinated select location, date, population, new_vaccinations, Cumulative_Vaccinations,Percent_of_Vaccinated  from
		(
		select cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.date) as Cumulative_Vaccinations, 
		(sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.date)/cd.population)*100 as Percent_of_Vaccinated 
		from Covid_Deaths cd inner join Covid_Vaccinations cv on cd.location=cv.location and cd.date=cv.date where cv.new_vaccinations is not null and cd.continent is not null)D;


		select location, max(population) as Population, max(Cumulative_Vaccinations) as Total_Vaccinations, round(max(Pop_Percent_Vaccinated),5) as Pop_Percent_Vaccinated from #Percent_Vaccinated 
		group by location
		order by location asc;








		--with cte along with VIEW

	
		with pop_vs_vac as (
		select cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.date) as Cumulative_Vaccinations
		from Covid_Deaths cd inner join Covid_Vaccinations cv on cd.location=cv.location and cd.date=cv.date where cv.new_vaccinations is not null and cd.continent is not null
		)
		select location, max(population) as Population, max(Cumulative_Vaccinations) as Total_Vaccinations, concat(round((max(Cumulative_Vaccinations)/max(population))*100,5),'%') as Percent_Vaccinated 
		from pop_vs_vac group by location order by location;



		create view View_Percent_Vaccinated  as
			with pop_vs_vac as (
		select cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.date) as Cumulative_Vaccinations
		from Covid_Deaths cd inner join Covid_Vaccinations cv on cd.location=cv.location and cd.date=cv.date where cv.new_vaccinations is not null and cd.continent is not null
		)
		select location, max(population) as Population, max(Cumulative_Vaccinations) as Total_Vaccinations, concat(round((max(Cumulative_Vaccinations)/max(population))*100,5),'%') as Percent_Vaccinated 
		from pop_vs_vac group by location;


		select * from View_Percent_Vaccinated ;