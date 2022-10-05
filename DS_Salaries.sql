use dssalaries;
select * from ds_salaries;

SELECT * 
FROM ds_salaries
LIMIT 10

/*How many countries are in the dataset*/
select count(distinct company_location) as number_of_countries
from dssalaries.ds_salaries

/*How many countries are there for non US countries and the US?*/
Select case when company_location = 'US' then "US"
	   ELSE "NonUS"
       END AS location,
       COUNT(company_location) as count_countries
FROM dssalaries.ds_salaries
GROUP BY location

/*What is the highest and lowest salary for US entries*/
(SELECT salary_in_usd AS US_salary_range
FROM ds_salaries
WHERE company_location = 'US'
ORDER BY salary_in_usd DESC
LIMIT 1)
UNION
(SELECT salary_in_usd AS US_salary_range
FROM ds_salaries
WHERE company_location = 'US'
ORDER BY salary_in_usd ASC
LIMIT 1)

/*What is the hihest and lowest salary for nonUS entries?*/
(SELECT salary_in_usd AS nonUS_salary_range
FROM ds_salaries
WHERE NOT company_location = 'US'
ORDER BY salary_in_usd DESC
LIMIT 1)
UNION (
SELECT salary_in_usd AS nonUS_salary_range
FROM ds_salaries
WHERE NOT company_location = 'US'
ORDER BY salary_in_usd
LIMIT 1)

/*What is the average salary for US and nonUS countries?*/
SELECT 
		CASE
			WHEN company_location = 'US' then "US"
		ELSE "nonUS"
        end as location,
	ROUND(AVG(salary_in_usd)) avg_salary
FROM ds_salaries
group by location
order by avg_salary desc

/*# What is the salary median for the US?*/
SELECT FLOOR(COUNT(company_location)/2) AS middle_row_number
FROM ds_salaries
WHERE company_location = 'US'

SELECT salary_in_usd AS median_number
FROM ds_salaries
WHERE company_location = 'US'
ORDER BY salary_in_usd
LIMIT 177,1

/*# What is the average salary for entries by experience level?*/
SELECT 
		CASE
			WHEN company_location = 'US' then "US"
		ELSE "nonUS"
        END AS location,
	ROUND(AVG(salary_in_usd),0) as average_salary,
		experience_level
from ds_salaries
group by location,experience_level
order by location, average_salary desc;

/*# What is the average salary for each year?*/
SELECT
		CASE 
			WHEN company_location = 'US' then "US"
		ELSE "nonUS"
        END AS location,
        work_year,
        round(avg(salary_in_usd),0) avg_salary
FROM ds_salaries
GROUP BY location, work_year
ORDER BY location desc, work_year

/*# How many senior and executive positions are in dataset for each year?*/
SELECT
	experience_level,
        count(experience_level) entries_experience_level,
        work_year
from ds_salaries
where experience_level in('SE','EX') AND company_location ="US"
GROUP BY work_year, experience_level

/*# What is the difference in entries amount for each year?*/
select a.work_year, sum(a.entries_exp_level) total_entries 
from
(SELECT work_year,count(experience_level) entries_exp_level
	   FROM ds_salaries
       WHERE company_location = 'US'
       GROUP BY work_year)a
group by work_year

/*# How many remote/hybrid/office positions are in each group?*/
SELECT 
		CASE
			WHEN company_location = 'US' then "US"
		ELSE "nonUS"
        END AS location,
        COUNT(IF(remote_ratio = 100,1,NULL)) remote,
		COUNT(IF(remote_ratio = 50,0,NULL)) hybrid,
        COUNT(IF(remote_ratio = 0,0,NULL)) office
FROM ds_salaries
GROUP BY location
ORDER BY remote desc

/*# What group has the highest percentage of remote positions?*/
(
SELECT
		CASE
			WHEN company_location = 'US' then "US_comapnies"
		END as location,
	ROUND(COUNT(IF(remote_ratio = 100,1,NULL)) / COUNT(remote_ratio) * 100,0) AS remote_percentage,
   	ROUND(COUNT(IF(remote_ratio = 50,0,NULL)) / COUNT(remote_ratio) * 100,0) AS hybrid_percentage,
	ROUND(COUNT(IF(remote_ratio = 0,0,NULL)) / COUNT(remote_ratio) * 100,0) AS office_percentage,
    COUNT(remote_ratio) as total_entries
FROM ds_salaries
GROUP BY location
ORDER BY total_entries DESC
)
UNION
(
SELECT 
		CASE
			WHEN company_location != 'US' then "nonUS_comapnies"
		END as location,
	ROUND(COUNT(IF(remote_ratio = 100,1,NULL)) / COUNT(remote_ratio) * 100,0) AS remote_percentage,
   	ROUND(COUNT(IF(remote_ratio = 50,0,NULL)) / COUNT(remote_ratio) * 100,0) AS hybrid_percentage,
	ROUND(COUNT(IF(remote_ratio = 0,0,NULL)) / COUNT(remote_ratio) * 100,0) AS office_percentage,
    COUNT(remote_ratio) as total_entries
FROM ds_salaries
WHERE NOT company_location = 'US'
GROUP BY location
ORDER BY total_entries DESC
)

/*# Does remote option affect the salary?*/
(SELECT
		CASE
			WHEN remote_ratio = '100' then "US_remote"
		WHEN remote_ratio = '50' then "US_hybrid"
        WHEN remote_ratio = '0' then "US_office"
        ELSE "null"
        END AS remote_ratio,
        ROUND(AVG(salary_in_usd),0) as average_salary
FROM ds_salaries
WHERE company_location = 'US'
GROUP BY remote_ratio
ORDER BY average_salary)
UNION
(SELECT
	CASE
			WHEN remote_ratio = '100' then "nonUS_remote"
		WHEN remote_ratio = '50' then "nonUS_hybrid"
        WHEN remote_ratio = '0' then "nonUS_office"
        ELSE "null"
        END AS remote_ratio,
        ROUND(AVG(salary_in_usd),0) as average_salary
FROM ds_salaries
WHERE NOT company_location = 'US'
GROUP BY remote_ratio
ORDER BY average_salary)

/*# What is the percentage of different experience positions working 100 remotely?*/
SELECT 
	CASE
		WHEN company_location = 'US' THEN "US"
        ELSE "nonUS"
	END AS location,
    ROUND(COUNT(IF(experience_level = 'EN', 1, NULL))/COUNT(experience_level) * 100, 0) AS entry_level,
    ROUND(COUNT(IF(experience_level = 'MI', 1, NULL))/COUNT(experience_level) * 100, 0) AS mid_level,
    ROUND(COUNT(IF(experience_level = 'SE', 1, NULL))/COUNT(experience_level) * 100, 0) AS senior_level,
    ROUND(COUNT(IF(experience_level = 'EX', 1, NULL))/COUNT(experience_level) * 100, 0) AS executive_level,
    COUNT(remote_ratio) AS total_entries
FROM ds_salaries
WHERE remote_ratio = '100'
GROUP BY location
ORDER BY total_entries DESC

/*# What is the percentage among different experience level ?*/
(SELECT 
	CASE
		WHEN experience_level = 'EN' THEN "US_entry_level"
        WHEN experience_level = 'MI' THEN "US_mid_level"
        WHEN experience_level = 'SE' THEN "US_senior_level"
        WHEN experience_level = 'EX' THEN "US_executive_level"
        ELSE "null"
	END AS experience_level,
    ROUND(COUNT(IF(remote_ratio = '100', 1, NULL))/COUNT(experience_level) * 100, 0) AS remote,
    ROUND(COUNT(IF(remote_ratio = '50', 1, NULL))/COUNT(experience_level) * 100, 0) AS hybrid,
    ROUND(COUNT(IF(remote_ratio = '0', 1, NULL))/COUNT(experience_level) * 100, 0) AS office,
    COUNT(remote_ratio) AS total_entries
FROM ds_salaries
WHERE company_location = 'US'
GROUP BY experience_level
)
UNION
(SELECT 
	CASE
		WHEN experience_level = 'EN' THEN "nonUS_entry_level"
        WHEN experience_level = 'MI' THEN "nonUS_mid_level"
        WHEN experience_level = 'SE' THEN "nonUS_senior_level"
        WHEN experience_level = 'EX' THEN "nonUS_executive_level"
        ELSE "null"
	END AS experience_level,
    ROUND(COUNT(IF(remote_ratio = '100', 1, NULL))/COUNT(experience_level) * 100, 0) AS remote,
    ROUND(COUNT(IF(remote_ratio = '50', 1, NULL))/COUNT(experience_level) * 100, 0) AS hybrid,
    ROUND(COUNT(IF(remote_ratio = '0', 1, NULL))/COUNT(experience_level) * 100, 0) AS office,
    COUNT(remote_ratio) AS total_entries
FROM ds_salaries
WHERE NOT company_location = 'US'
GROUP BY experience_level
)

/*# How many entries are there for different employment type and what is the average salary?*/
SELECT 
	CASE
		WHEN company_location = 'US' THEN "US"
        ELSE "nonUS"
	END AS location,
	ROUND(avg(salary_in_usd),0) AS average_salary, 
	COUNT(employment_type) AS total_employment_type,
	employment_type
FROM ds_salaries
GROUP BY location, employment_type
ORDER BY location, average_salary DESC

/*# What is the percentage of different employment type for each group US vs. nonUS?*/
SELECT 
	CASE
		WHEN company_location = 'US' THEN "US"
        ELSE "nonUS"
	END AS location,
	ROUND(COUNT(IF(employment_type = 'FT', 1, NULL))/COUNT(employment_type) * 100, 0) AS fulltime,
    ROUND(COUNT(IF(employment_type = 'PT', 1, NULL))/COUNT(employment_type) * 100, 0) AS parttime, 
    ROUND(COUNT(IF(employment_type = 'FL', 1, NULL))/COUNT(employment_type) * 100, 0) AS freelance,
    ROUND(COUNT(IF(employment_type = 'CT', 1, NULL))/COUNT(employment_type) * 100, 0) AS contract,
    COUNT(employment_type) AS total_entries
FROM ds_salaries
GROUP BY location

/*# How many different titles are there in the dataset and what data position is the most frequent?*/
SELECT COUNT(distinct job_title) AS job_count
FROM ds_salaries

SELECT job_title,
	COUNT(job_title) AS count_jobs
FROM ds_salaries
GROUP BY job_title
ORDER BY count_jobs DESC
LIMIT 10

/*# Does bigger companies allows remote positions more than small or medium companies? */
SELECT 
	CASE
		WHEN company_location = 'US' THEN "US"
        ELSE "nonUS"
	END AS location,
    company_size,
	ROUND(COUNT(IF(remote_ratio = '100', 1, NULL))/COUNT(remote_ratio) * 100, 0) AS remote_percentage,
	ROUND(COUNT(IF(remote_ratio = '50', 1, NULL))/COUNT(remote_ratio) * 100, 0) AS hybrid_percentage,
	ROUND(COUNT(IF(remote_ratio = '0', 1, NULL))/COUNT(remote_ratio) * 100, 0) AS office_percentage
FROM ds_salaries
GROUP BY location, company_size

/*# Is the average salary higher for bigger companies? */
SELECT 
	CASE
		WHEN company_location = 'US' THEN "US"
        ELSE "nonUS"
	END AS location,
    ROUND(AVG(salary_in_usd),0) as average_salary,
	company_size
FROM ds_salaries
GROUP BY location, company_size
ORDER BY location, average_salary DESC

/*# How many related positions are there by company size?*/
SELECT 
    company_size,
	COUNT(job_title) as total_positions
FROM ds_salaries
GROUP BY company_size
ORDER BY total_positions DESC

/*# Does large companies have more people working on senior and executive positions than small companies?*/
SELECT 
	CASE
		WHEN company_location = 'US' THEN "US"
        ELSE "nonUS"
	END AS location,
    company_size, 
	COUNT(IF(experience_level = 'SE' OR 'EX',1, NULL)) as SE_EX_positions
FROM ds_salaries
GROUP BY location, company_size
ORDER BY location, SE_EX_positions

/*# How many people are in a different country than it is the company headquarters?*/
SELECT
		CASE
			WHEN company_location = employee_residence then "Same"
		ELSE "different"
        END AS matching_countries,
	ROUND(COUNT(company_location)/607 * 100,1) AS number_of_positions
FROM ds_salaries
GROUP BY matching_countries
