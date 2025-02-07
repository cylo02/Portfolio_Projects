-- HR Analytics

-- What is the current population of the employees in the company?

SELECT COUNT(*) AS num_of_employees
FROM hr_analytics
WHERE attrition = 'No';

-- What is the gender breakdown of the employees in the company?

SELECT gender, COUNT(gender)AS num_of_employees
FROM hr_analytics
WHERE age >= 18 
GROUP BY gender;

-- What is the age distribution of the employees in the company?

SELECT Age, COUNT(Age) AS Population
FROM hr_analytics
GROUP BY Age;

SELECT 
	CASE 
		WHEN Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN Age BETWEEN 25 AND 30 THEN '25-30'
        WHEN Age BETWEEN 31 AND 36 THEN '31-36'
        WHEN Age BETWEEN 37 AND 42 THEN '37-42'
        WHEN Age BETWEEN 43 AND 48 THEN '43-48'
        WHEN Age BETWEEN 49 AND 54 THEN '49-54'
		ELSE '55+'
	END	AS age_group,
	COUNT(*) AS num_of_employees
FROM hr_analytics
GROUP BY age_group;

SELECT DISTINCT JobRole
FROM hr_analytics;

-- How does the gender distribution/count vary across job titles and departments?

SELECT 
	JobRole,
    Department,
    COUNT(*) AS Total_Count, 
    ROUND(COUNT(CASE WHEN gender = 'Male' THEN 1 END) * 100.0 / COUNT(*),2) AS male_percentage,
    ROUND(COUNT(CASE WHEN gender = 'Female' THEN 1 END) * 100.0 / COUNT(*),2) AS female_percentage
FROM hr_analytics
GROUP BY JobRole, Department
ORDER BY JobRole, Department;

-- What is the distribution/count of job titles across the company?

WITH gender_count AS (
    SELECT 
        JobRole,
        Department,
        COUNT(*) AS Total_Count, 
        COUNT(CASE WHEN gender = 'Male' THEN 1 END) AS Male_Count,
        COUNT(CASE WHEN gender = 'Female' THEN 1 END) AS Female_Count
    FROM hr_analytics
    GROUP BY JobRole, Department
),
gender_percentage AS (
    SELECT 
        JobRole,
        Department, 
        Total_Count,
        Male_Count,
        Female_Count,
        ROUND((Male_Count * 100.0 / Total_Count), 1) AS Male_Perc, 
        ROUND((Female_Count * 100.0 / Total_Count), 1) AS Female_Perc
    FROM gender_count
)
SELECT 
    JobRole,
    Department, 
    Total_Count,
    Male_Count,
    Female_Count,
    Male_Perc,
    Female_Perc,
    CASE 
        WHEN Male_Perc > 70 THEN 'Male-Dominated' 
        WHEN Female_Perc > 70 THEN 'Female-Dominated' 
        ELSE 'Balanced' 
    END AS Gender_Category,
    RANK() OVER (ORDER BY ABS(Male_Perc - Female_Perc) ASC) AS Gender_Balance_Rank
FROM gender_percentage
ORDER BY Gender_Balance_Rank, Department, JobRole;
