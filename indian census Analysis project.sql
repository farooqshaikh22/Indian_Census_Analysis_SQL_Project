-- 1.Number of rows in dataset
select count(1)total_rows from district_census_2011

-- 2.Dataset for Gujarat
select * from district_census_2011 where state = 'Gujarat'

-- 3.what is population of india?
select sum(cast(replace(population,',','')as numeric))total_indian_population from district_census_2011

-- 4. Average growth of India
select avg(cast(replace(growth,'%','')as numeric))avg_growth from district_census_2011

-- 5.Average growth by state
select state,avg(cast(replace(growth,'%','')as numeric))avg_growth from district_census_2011
group by state order by state

-- 6.Average sex ratio
select round(avg(sex_ratio),0)avg_sex_ratio from district_census_2011

-- 7.Average sex ratio by state
select state,round(avg(sex_ratio),0)avg_sex_ratio from district_census_2011
group by state order by avg_sex_ratio desc

-- 8.Top 2 state with highest average literacy 

select state,round(avg(literacy),0)avg_literacy_ratio from district_census_2011
group by state
having round(avg(literacy),0) > 90
order by avg_literacy_ratio desc 

-- 9. Top 3 states with highest growth rates

select state,round(avg(cast(replace(growth,'%','')as numeric)),0)avg_growth from district_census_2011
group by state order by avg_growth desc
limit 3

-- 10.Bottom 3 states with lowest sex ratio
select state,round(avg(sex_ratio),0)avg_sex_ratio from district_census_2011
group by state order by avg_sex_ratio asc
limit 3

-- 11.top 3 and bottom 3 state with average growth
with t1 (state,avg_growth)
as(
select state,round(avg(cast(replace(growth,'%','')as numeric)),0)avg_growth from district_census_2011
group by state

)
(select state,avg_growth from t1 order by avg_growth desc limit 3)
union all
(select state,avg_growth from t1 order by avg_growth asc limit 3)

-- 12.top 3 and bottom 3 state with average literacy
with t2(state,avg_literacy)
as(
select state,round(avg(literacy),0)avg_literacy from district_census_2011
	group by state
)
(select * from t2 order by avg_literacy desc limit 3)
union all
(select * from t2 order by avg_literacy asc limit 3)

-- 13.States starting with letter 'A'
select distinct state from district_census_2011 where lower(state) like 'a%'

-- 14.States starting with letter 'A' and ending with letter 'M'
select distinct state from district_census_2011 
where lower(state) like 'a%' and  lower(state) like '%m'

-- 15.number of male and female per state.

select b.state,sum(b.male_population)male,sum(b.female_population)female from
(select a.district,a.state,total_population,round(a.total_population/(1 + a.sex_ratio),0)male_population,
round((a.total_population *a.sex_ratio)/(1 + a.sex_ratio),0)female_population 
from
(select district,state,cast(replace(population,',','')as numeric)total_population,
 sex_ratio/1000 sex_ratio from district_census_2011)a)b
 group by state order by state
 
-- 16.Total literate and illiterate people per state 
select b.state,sum(b.total_population)total_population,sum(b.literate_people)literate_people,sum(b.illiterate_people)illiterate_people from
(select a.district,a.state,round((a.literacy) * (a.total_population),0) literate_people,
round(a.total_population*(1-a.literacy ),0)illiterate_people,total_population
from
(select district,state,
cast(replace(population,',','')as numeric)total_population,
literacy/100 literacy from district_census_2011)a)b
group by b.state
order by state

-- 17.What is the population in previous census?
select a.district,a.state,a.current_population,
round(a.current_population/(1+a.growth_rate),0)previous_population from
(select district,state,cast(replace(population,',','')as numeric)current_population,
cast(replace(growth,'%','')as decimal)/100 growth_rate
from district_census_2011)a

-- 18.Output top 3 districts from each state with highest literacy rate
select * from district_census_2011
select a.* from
(select district,state,literacy,
rank() over(partition by state order by district desc)rnk from
district_census_2011)a
where rnk in (1,2,3)