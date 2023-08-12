use [Portfolio Project];





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


		--VIEW
		create view View_Country_Total_Deaths as
		  select location, total_deaths as Total_Deaths, CONVERT(VARCHAR(8), date, 3) AS Date from Covid_Deaths  
		where continent is not null and total_deaths is not null;
  
  select * from  View_Country_Total_Deaths;

        --Visualize
        --looking at death rates

        select location, max(date) as latest_date ,max(total_cases) as Total_Cases, max(total_deaths) as Total_Deaths,
	    round((max(total_deaths)/max(total_cases)),4) as Death_Rate 
        from Covid_Deaths  where continent is not null  
		group by location having round((max(total_deaths)/max(total_cases)),4)  is not null order by Death_Rate desc;


		--VIEW
		create view View_Country_Death_Rate as
		  select location, max(date) as latest_date ,max(total_cases) as Total_Cases, max(total_deaths) as Total_Deaths,
	    round((max(total_deaths)/max(total_cases)),4) as Death_Rate 
        from Covid_Deaths  where continent is not null  
		group by location having round((max(total_deaths)/max(total_cases)),4)  is not null;


		 
        --Visualize
        --looking at infection rate

        ----using group by clause
        select top 20 location, max(total_cases) as Total_Cases, max(population) as Population, max(total_cases)/max(population) as Infection_Rate 
        from Covid_Deaths  where continent is not null  
		group by location having max(total_cases)/max(population) is not null order by Infection_Rate desc;


		--VIEW
		create view View_Country_Infection_Rate as
		  select location, max(total_cases) as Total_Cases, max(population) as Population, max(total_cases)/max(population) as Infection_Rate 
        from Covid_Deaths  where continent is not null  
		group by location having max(total_cases)/max(population) is not null;



        ---- using cte
        with cte as (select location, max(population) as Population, max(total_cases) as Total_Cases, 
		concat(round(max(total_cases)/max(population),5),'%') as Infection_Percentage 
        from Covid_Deaths  where continent is not null  
		group by location having max(total_cases)/max(population) is not null) SELECT * FROM cte;



        ----using ranked window function
        select distinct * from 
        (select location, population, total_cases ,total_cases/population as Infection_Rate, 
		dense_rank() over (partition by location order by total_cases desc) as rank_ 
        from Covid_Deaths where (total_cases/population) is not null) D
        where rank_=1 order by Infection_Rate desc;


 

        --Visualize
        --looking at country-wise deaths per million

        select distinct location, population, total_deaths, (total_deaths/population)*1000000 as Deaths_per_million, rank_ from
        (select location, population, total_deaths, (total_deaths/population)*1000000 as Deaths_per_million , 
		dense_rank() over (partition by location order by (total_deaths/population)  desc) as rank_
        from Covid_Deaths) D where rank_=1 and (total_deaths/population) is not null order by (total_deaths/population)*1000000 desc;


		select location, max(population) as Population, (sum(cast(new_deaths as int))/max(population))*1000000 as Total_Deaths_per_million from Covid_Deaths 
		where continent is not null 
		group by location having (sum(cast(new_deaths as int))/max(population))*1000000 is not null 
		order by (sum(cast(new_deaths as int))/max(population))*1000000 desc;
	

        --VIEW
	    create view View_Country_Deaths_per_Million_Country as
			select location, max(population) as Population, (sum(cast(new_deaths as int))/max(population))*1000000 as Total_Deaths_per_million from Covid_Deaths 
		where continent is not null 
		group by location having (sum(cast(new_deaths as int))/max(population))*1000000 is not null ;











--LOOKING AT CONTINENT-WISE


 --mapping of continent and country
         select distinct continent, location from Covid_Deaths where continent is not null order by continent;
         

	

	    --Visualize
        --looking at total deaths

	   --1st method
		select location as Continent, max(cast(total_deaths as int)) as Total_Deaths from Covid_Deaths where continent is null and location not in ('World','International','European Union') group by location
		order by  max(cast(total_deaths as int)) desc;


		--2nd method
        select continent, sum(Total_Deaths) as Total_Deaths, sum(Population) as Population from
		(select distinct cd.continent, mid.Country, mid.Total_Deaths, mid.Population from Covid_Deaths cd inner join
		(select location as Country, max(cast(total_deaths as int)) as Total_Deaths, max(population) as Population from Covid_Deaths where continent is not null 
		group by location having max(cast(total_deaths as int)) is not null)mid on cd.location=mid.Country and cd.Total_Deaths=mid.Total_Deaths)final 
		group by final.continent;
	




	--Visualize
	     --looking at death rates


		 --mapping of continent and country
         select distinct continent, location from Covid_Deaths where continent is not null order by continent;

   
		 select continent, sum(Total_Deaths) as Total_Deaths, sum(Total_Cases) as Total_Cases, sum(Population) as Population, sum(Total_Deaths)/sum(Total_Cases) as Death_Rate from
		 (select distinct cd.continent, D.location, D.Total_Deaths, D.Population, D.Total_Cases, D.Death_Rate from Covid_Deaths cd inner join
		 (select location, max(cast(total_deaths as int)) as Total_Deaths, max(population) as Population, max(total_cases) as Total_Cases, 
		 max(cast(total_deaths as int))/max(total_cases) as Death_Rate
		 from Covid_Deaths where continent is not null group by location having max(cast(total_deaths as int)) is not null) D 
		 on cd.location=D.location and cd.Total_Deaths=D.Total_Deaths) E
		 group by continent;




		 
                --Visualize
		--looking at Infection_Rate

		--simple
		--select location as continent, max(total_cases) as Total_Cases, max(population) as Population, max(total_cases)/max(population) as Infection_Rate
		--from Covid_Deaths where continent is null and location not in('World', 'European Union', 'International') group by location;



		--2nd method
		--using temp table and cte
		create table #temptable (
		continent nvarchar(255),
		Total_Cases float,
		Population float
		)


		
		with cte as 
		(
		select location, max(total_cases) as Total_Cases, max(population) as Population
		from Covid_Deaths where continent is not null group by location having max(total_cases) is not null
		)
		insert into #temptable select continent, Total_Cases, Population from
		(
		select distinct cd.continent, C.location, C.Total_Cases, C.Population from Covid_Deaths cd inner join cte C on cd.location=C.location and cd.total_cases=C.Total_Cases
		)D;

		select * from #temptable;

		select continent as Continent, sum(Total_cases) as Total_Cases, sum(Population) as Population, sum(Total_cases)/sum(Population) as Infection_Rate from #temptable group by continent;


			

        --Visualize
		--looking at deaths per million


		--1st method direct using 'continents' present in location column

		select location as Continent, max(cast(total_deaths as int)) as Total_Deaths, max(population) as Population, (max(cast(total_deaths as int))/ max(population))*1000000 
		as deaths_per_million from Covid_Deaths where continent is null and location not in ('World','International','European Union') group by location 
		order by (max(cast(total_deaths as int))/ max(population))*1000000  desc;




		--2nd method finding the sum of individual countries and then aggregating

		create table #temp_million (
		Continent nvarchar(255),
		Total_Deaths float,
		Population float
		)

		drop table #temp_million;

		with cte as (
		select location, max(cast(total_deaths as int)) as Total_Deaths, max(population) as Population from Covid_Deaths where continent is not null
		group by location  having max(cast(total_deaths as int)) is not null
		)
	    	insert into #temp_million select distinct continent, Total_Deaths, Population from (
		select cd.continent, C.location, C.Total_Deaths, C.Population from Covid_Deaths cd inner join cte C on 
		cd.location=C.location and cd.total_deaths=C.Total_Deaths)D

		select * from #temp_million;
		
		select Continent, sum(Total_Deaths) as Total_Deaths, sum(Population) as Population, (sum(Total_Deaths)/sum(Population))*1000000 as Deaths_per_Million from #temp_million
		group by Continent;




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

 

        --using CTE and subqueries

		

		--1 (country wise)
		with pop_vs_test as(
		select cd.location, cd.date, cd.population, cv.new_tests as Tests_per_day, sum(cast(cv.new_tests as int)) over (partition by cd.location order by cd.date) as Cumulative_Tests
		from  Covid_Deaths cd inner join Covid_Vaccinations cv on cd.location=cv.location and cd.date=cv.date where cv.new_tests is not null
		)
		select location, max(date) as Date, max(population) as Population, max(Cumulative_Tests) as Total_Tests, (max(Cumulative_Tests)/max(population)) as Tests_per_Person 
		from pop_vs_test group by location order by location  asc;



		--2 (continent-wise in which join done bw covid_death and covid_vaccination) (in this only those countries pop. considered who have done tests)
		select E.continent as Continent, sum(E.Total_Tests) as Total_Tests, sum(E.Population) as Population,  sum(E.Total_Tests)/sum(E.Population) as Tests_per_Person from
		(select distinct cd.continent, D.location, D.Total_Tests, D.Population from Covid_Deaths cd inner join
		(select cv.location, max(cast(cv.total_tests as int)) as Total_Tests, max(cd.population) as Population from Covid_Vaccinations cv inner join Covid_Deaths cd on cv.location=cd.location and cv.date=cd.date  
		where cv.continent is not null
		group by cv.location having  max(cv.total_tests)  is not null)D
		on cd.location=D.location)E 
		group by E.continent;



		
		--3 continent-wise but diff from above as in above populations of country that did not conduct tests not counted in above so population taken from covid_death and 
                --total_tests taken from covid_vaccinations 
		--Visualize

		select A.continent, A.Total_Tests, B.Population, A.Total_Tests/B.Population as Tests_per_Person from
		(select continent, sum(Total_Tests) as Total_Tests from
		(select map.continent, map.location, country_tests.Total_Tests as Total_Tests from
		(select cv.location, max(cast(cv.total_tests as int)) as Total_Tests, max(cd.population) as Population from Covid_Vaccinations cv inner join Covid_Deaths cd on cv.location=cd.location and cv.date=cd.date  
		where cv.continent is not null
		group by cv.location having  max(cv.total_tests)  is not null) country_tests 
		inner join (select distinct continent, location from Covid_Deaths where continent is not null) map on country_tests.location=map.location) country
		group by continent) A inner join
		--considering all populations of continents
        (select location as continent, max(population) as Population from Covid_Deaths where continent is null and location not in ('World','International','European Union') 
		group by location) B on A.continent=B.continent;




		--4
		
		select map.continent, map.location, map.population, country_tests.Total_Tests as Total_Tests, country_tests.Total_Tests/map.population as Tests_Per_Person from
		(select cv.location, max(cast(cv.total_tests as int)) as Total_Tests, max(cd.population) as Population from Covid_Vaccinations cv inner join Covid_Deaths cd on cv.location=cd.location and cv.date=cd.date  
		where cv.continent is not null
		group by cv.location having  max(cv.total_tests)  is not null) country_tests 
		inner join (select distinct continent, location, population from Covid_Deaths where continent is not null) map on country_tests.location=map.location;







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

		
		
		--using subqueries and cte
		--Visualized
		

		--finding pop of continent using only those countries that provided vaccinations data

		with cte as(select B.continent, A.location, A.Total_Vaccinations, A.Population from
		(select cv.location, max(cast(cv.total_vaccinations as int)) as Total_Vaccinations, max(cd.population) as Population 
		from Covid_Deaths cd inner join Covid_Vaccinations cv on cd.location=cv.location and cd.date=cv.date 
		group by cv.location having max(cast(cv.total_vaccinations as int)) is not null) A 
		inner join 
		(select distinct continent, location from Covid_Deaths where continent is not null) B 
		on A.location=B.location
		)
		select continent, sum(Total_Vaccinations) as Total_Vaccinations, sum(Population) as Population, (sum(Total_Vaccinations)/sum(Population))*100 as Percent_Vaccinated  from cte
		group by continent;







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
