--Drop schema SAP_PROJECT.PUBLIC;

-- 1. Create a file format for key-value pairs
CREATE OR REPLACE FILE FORMAT kv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ': '
  SKIP_HEADER = 0
  FIELD_OPTIONALLY_ENCLOSED_BY = NONE
  TRIM_SPACE = TRUE;

-- 2. Create a staging table to load raw key-value pairs
CREATE OR REPLACE TABLE raw_kv_pairs (
  line STRING
);

-- 3. Load the file into the staging table
COPY INTO raw_kv_pairs
FROM @my_stage/user_comments.txt
FILE_FORMAT = (FORMAT_NAME = kv_format)
ON_ERROR = 'CONTINUE';

-- 4. Parse key-value pairs into structured columns using Snowflake SQL
-- Create a final structured table
CREATE OR REPLACE TABLE product_reviews (
  product_id STRING,
  product_title STRING,
  product_price STRING,
  user_id STRING,
  profile_name STRING,
  helpfulness STRING,
  score FLOAT,
  review_time TIMESTAMP_NTZ,
  summary STRING,
  review_text STRING
);

-- 5. Transform and insert structured data
INSERT INTO product_reviews
SELECT
  MAX(CASE WHEN line LIKE 'product/productId:%' THEN SPLIT_PART(line, ': ', 2) END) AS product_id,
  MAX(CASE WHEN line LIKE 'product/title:%' THEN SPLIT_PART(line, ': ', 2) END) AS product_title,
  MAX(CASE WHEN line LIKE 'product/price:%' THEN SPLIT_PART(line, ': ', 2) END) AS product_price,
  MAX(CASE WHEN line LIKE 'review/userId:%' THEN SPLIT_PART(line, ': ', 2) END) AS user_id,
  MAX(CASE WHEN line LIKE 'review/profileName:%' THEN SPLIT_PART(line, ': ', 2) END) AS profile_name,
  MAX(CASE WHEN line LIKE 'review/helpfulness:%' THEN SPLIT_PART(line, ': ', 2) END) AS helpfulness,
  MAX(CASE WHEN line LIKE 'review/score:%' THEN TRY_TO_NUMBER(SPLIT_PART(line, ': ', 2)) END) AS score,
  MAX(CASE WHEN line LIKE 'review/time:%' THEN TO_TIMESTAMP(SPLIT_PART(line, ': ', 2)) END) AS review_time,
  MAX(CASE WHEN line LIKE 'review/summary:%' THEN SPLIT_PART(line, ': ', 2) END) AS summary,
  MAX(CASE WHEN line LIKE 'review/text:%' THEN SPLIT_PART(line, ': ', 2) END) AS review_text
FROM raw_kv_pairs
QUALIFY ROW_NUMBER() OVER (ORDER BY NULL) % 10 = 1  -- Adjust if multiple reviews per file
GROUP BY CEIL(ROW_NUMBER() OVER (ORDER BY NULL) / 10);  -- Group every 10 lines as one review
