select * from Data1
select * from Data2

-- Total no. of rows in Dataset1
select COUNT(*) as Total_Rows_Data1 from PROJECT..Data1
select COUNT(*) as Total_Rows_Data2 from PROJECT..Data2

-- Filter dataset for Bihar and Jharkhand

select * from PROJECT..Data1 where State in ('Bihar', 'Jharkhand')

-- Population of India

select SUM(Population) as Indias_Population from Data2

-- Average Growth of India

select AVG(Growth)*100 as Growth_Percentage from Data1

-- Average Growth by State

select State, AVG(Growth)*100 as Statewise_Growth_Percentage from Data1 group by State

-- Average Sex Ratio

select State, AVG(Sex_Ratio) as Avg_Sex_Ratio from Data1 group by State

select State, ROUND(AVG(Sex_Ratio),0) as Avg_Sex_Ratio 
from Data1 
group by State 
order by Avg_Sex_Ratio desc

-- Average Literacy Rate

select State, ROUND(AVG(Literacy),0) as Avg_Literacy_Rate 
from Data1 
group by State 
having ROUND(AVG(Literacy),0) > 90 
order by Avg_Literacy_Rate desc

-- Top 3 state showing highest growth ratio

select top 3 State, ROUND(AVG(Growth)*100,0) as Highest_Growth_Ratio 
from Data1 
group by State 
order by Highest_Growth_Ratio desc

-- Bottom 3 state having lowest sex ratio

select top 3 State, ROUND(AVG(Sex_Ratio),0) as Lowest_Sex_Ratio 
from Data1 
Group by State
order by Lowest_Sex_Ratio

-- Top and Bottom 3 states in literacy rate

drop table if exists #topstates
create table #topstates
(state nvarchar(50),
topstate float)

insert into #topstates
select State, ROUND(AVG(Literacy),0)as Avg_Literacy_Ratio 
from PROJECT..Data1
group by State
order by Avg_Literacy_Ratio desc

select top 3 * from #topstates order by #topstates.topstate desc

-- ------------------------------------------------------------------------------------

drop table if exists #bottomstates
create table #bottomstates
(state nvarchar(50),
bottomstate float)

insert into #bottomstates
select State, ROUND(AVG(Literacy),0)as Avg_Literacy_Ratio 
from PROJECT..Data1
group by State
order by Avg_Literacy_Ratio desc

select top 3 * from #bottomstates order by #bottomstates.bottomstate

-- Union Operation

select * from 
(select top 3 * from #topstates order by #topstates.topstate desc) a
union
select * from 
(select top 3 * from #bottomstates order by #bottomstates.bottomstate) b

-- States starting with letter A

select distinct(State) from PROJECT..Data1 where State like 'A%'

-- Joining Both Tables

select A.District, A.State, A.Sex_Ratio/1000 as Sex_Ratio, B.Population 
from PROJECT..Data1 as A 
join 
PROJECT..Data2 as B 
on A.District = B.District

-- No. of Males and Females count

select C.State, C.District, C.Population, ROUND((C.Population)/(C.Sex_Ratio + 1),0) as Male_Count, 
ROUND((C.Population - (C.Population)/(C.Sex_Ratio + 1)),0) as Female_Count 
from 
(select A.District, A.State, A.Sex_Ratio/1000 as Sex_Ratio, B.Population 
from PROJECT..Data1 as A 
join 
PROJECT..Data2 as B 
on A.District = B.District) as C

-- Statewise Male Count and Female Count

select State, SUM(D.Male_Count) as Toatal_Male, SUM(D.Female_Count) as Total_Female from 
(select C.State, C.District, C.Population, ROUND((C.Population)/(C.Sex_Ratio + 1),0) as Male_Count, 
ROUND((C.Population - (C.Population)/(C.Sex_Ratio + 1)),0) as Female_Count 
from 
(select A.District, A.State, A.Sex_Ratio/1000 as Sex_Ratio, B.Population 
from PROJECT..Data1 as A 
join 
PROJECT..Data2 as B 
on A.District = B.District) as C) as D 
group by D.State

-- Literacy Rate

select C.State, ROUND(((C.Literacy_Ratio*C.Population)/100),0) as Literacy_Count, ROUND((((1 - C.Literacy_Ratio)*C.Population)/100),0) as Illiteracy_Count from 
(select A.District, A.State, A.Literacy/100 as Literacy_Ratio, B.Population 
from PROJECT..Data1 as A 
join 
PROJECT..Data2 as B 
on A.District = B.District ) as C 

-- Statewise Literate & Illiterate Peoples

select D.State, SUM(Literacy_Count) as Literate_People, SUM(Illiteracy_Count) as Illiterate_People from
(select C.State, ROUND(((C.Literacy_Ratio*C.Population)/100),0) as Literacy_Count, ROUND((((1 - C.Literacy_Ratio)*C.Population)/100),0) as Illiteracy_Count from 
(select A.District, A.State, A.Literacy/100 as Literacy_Ratio, B.Population 
from PROJECT..Data1 as A 
join 
PROJECT..Data2 as B 
on A.District = B.District ) as C ) as D group by State

-- Population in previous census

select C.State, C.District, ROUND((C.Population / (1+C.Growth)),0) as Previous_Year_Population from
(select A.District, A.State, A.Growth, B.Population 
from PROJECT..Data1 as A 
join 
PROJECT..Data2 as B 
on A.District = B.District) as C

-- Statewise populationb in previous year

select D.State, SUM(Previous_Year_Population) as Statewise_PY_Population from 
(select C.State, C.District, C.Population, ROUND((C.Population / (1+C.Growth)),0) as Previous_Year_Population from
(select A.District, A.State, A.Growth, B.Population 
from PROJECT..Data1 as A 
join 
PROJECT..Data2 as B 
on A.District = B.District) as C ) as D group by State 

-- Indias population in previous year

select SUM(E.Statewise_PY_Population) as Indias_PY_Population from 
(select D.State, SUM(Previous_Year_Population) as Statewise_PY_Population from 
(select C.State, C.District, C.Population, ROUND((C.Population / (1+C.Growth)),0) as Previous_Year_Population from
(select A.District, A.State, A.Growth, B.Population 
from PROJECT..Data1 as A 
join 
PROJECT..Data2 as B 
on A.District = B.District) as C ) as D group by State ) as E

-- Population & Area

select '1' as keyy, X.* from 
(select SUM(E.Statewise_PY_Population) as Indias_PY_Population from 
(select D.State, SUM(Previous_Year_Population) as Statewise_PY_Population from 
(select C.State, C.District, C.Population, ROUND((C.Population / (1+C.Growth)),0) as Previous_Year_Population from
(select A.District, A.State, A.Growth, B.Population 
from PROJECT..Data1 as A 
join 
PROJECT..Data2 as B 
on A.District = B.District) as C ) as D group by State ) as E ) as X

select '1' as keyy, Y.* from 
(select SUM(Area_km2) as Area from PROJECT..Data2) as Y

-- Population vs Area

select M.*, N.* from 
(select '1' as keyy, X.* from 
(select SUM(E.Statewise_PY_Population) as Indias_PY_Population from 
(select D.State, SUM(Previous_Year_Population) as Statewise_PY_Population from 
(select C.State, C.District, C.Population, ROUND((C.Population / (1+C.Growth)),0) as Previous_Year_Population from
(select A.District, A.State, A.Growth, B.Population 
from PROJECT..Data1 as A 
join 
PROJECT..Data2 as B 
on A.District = B.District) as C ) as D group by State ) as E ) as X ) as M 
inner join 
(select '1' as keyy, Y.* from 
(select SUM(Area_km2) as Area from PROJECT..Data2) as Y ) as N 
on M.keyy = N.keyy

-- Previous Population vs Area

select P.Area/P.Indias_PY_Population as Previous_Population_vs_Area from 
(select M.*, N.Area from 
(select '1' as keyy, X.* from 
(select SUM(E.Statewise_PY_Population) as Indias_PY_Population from 
(select D.State, SUM(Previous_Year_Population) as Statewise_PY_Population from 
(select C.State, C.District, C.Population, ROUND((C.Population / (1+C.Growth)),0) as Previous_Year_Population from
(select A.District, A.State, A.Growth, B.Population 
from PROJECT..Data1 as A 
join 
PROJECT..Data2 as B 
on A.District = B.District) as C ) as D group by State ) as E ) as X ) as M 
inner join 
(select '1' as keyy, Y.* from 
(select SUM(Area_km2) as Area from PROJECT..Data2) as Y ) as N 
on M.keyy = N.keyy ) as P

-- Rank

select State, District, Literacy, RANK() over (partition by State order by Literacy desc) as Rank_No from PROJECT..Data1 

-- Rank
-- Top 3 districts from each State with Highest Literacy Rate

select A.* from
(select State, District, Literacy, RANK() over (partition by State order by Literacy desc) as Rank_No from PROJECT..Data1) as a
where A.Rank_No in (1, 2, 3) order by State
