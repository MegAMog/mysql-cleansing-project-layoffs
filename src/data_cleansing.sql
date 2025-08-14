-- Data cleansing
USE db_layoffs;

-- Explore raw data
SELECT *
FROM raw_layoffs
LIMIT 100;

-- Create staging data
CREATE TABLE staging_layoffs
LIKE raw_layoffs;

INSERT staging_layoffs
SELECT *
FROM raw_layoffs;


-- 1. Standardize data
-- Go over quality data columns and analyze
SELECT 
count(distinct company), count(distinct trim(company)), count(distinct trim(lower(company))),
count(distinct location), count(distinct trim(location)), count(distinct trim(lower(location))),
count(distinct industry), count(distinct trim(industry)), count(distinct trim(lower(industry))),
count(distinct stage), count(distinct trim(stage)), count(distinct trim(lower(stage))),
count(distinct country), count(distinct trim(country)), count(distinct trim(lower(country)))
FROM staging_layoffs;

-- Remove spaces in company -> trim
UPDATE staging_layoffs
SET company = trim(company);

-- Analyze typos/mistakes in industry
SELECT DISTINCT industry
FROM staging_layoffs
ORDER BY 1;

-- Update industry
UPDATE staging_layoffs
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Analyze typos/mistakes in country
SELECT DISTINCT country
FROM staging_layoffs
ORDER BY 1;

-- Update country
UPDATE staging_layoffs
SET country = TRIM(TRAILING '.' FROM country);

-- Standartize data types
-- date
UPDATE staging_layoffs
SET date = STR_TO_DATE(date, '%m/%d/%YYYY');

ALTER TABLE staging_layoffs
MODIFY COLUMN date DATE;

-- total_laid_off, funds_raised_millions, percentage_laid_off
ALTER TABLE staging_layoffs
MODIFY COLUMN total_laid_off INT;

ALTER TABLE staging_layoffs
MODIFY COLUMN funds_raised_millions INT;

ALTER TABLE staging_layoffs
MODIFY COLUMN percentage_laid_off FLOAT;


-- 2. NULL, blank values
SELECT *
FROM staging_layoffs
WHERE industry is NULL or industry='';

-- Airbnb, Bally's Interactive, Juul, Carvana
SELECT *
FROM staging_layoffs
WHERE company IN ('Airbnb', "Bally's Interactive", 'Juul', 'Carvana')
ORDER by company;

-- Airbnb -> Travel
-- Carvana -> Transportation
-- Juul -> Consumer
UPDATE staging_layoffs as t1
JOIN staging_layoffs as t2 ON t1.company=t2.company
SET t1.industry=t2.t1.industry
WHERE t1.industry IS NULL and t2.industry IS NOT NULL;

-- 3. Remove duplicates
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) as row_num
FROM staging_layoffs
ORDER BY row_num DESC;

WITH duplicates_cte AS
(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) as row_num
FROM staging_layoffs
)
SELECT *
FROM duplicates_cte
WHERE row_num>1;	

-- DELETE duplicates
CREATE TABLE staging_layoffs_non_duplicates (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` float DEFAULT NULL,
  `date` date DEFAULT NULL,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
);

INSERT INTO staging_layoffs_non_duplicates
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) as row_num
FROM staging_layoffs;

SELECT *
FROM staging_layoffs_non_duplicates;

DELETE
FROM staging_layoffs_non_duplicates
WHERE row_num>1;

ALTER TABLE staging_layoffs_non_duplicates
DROP COLUMN row_num;
