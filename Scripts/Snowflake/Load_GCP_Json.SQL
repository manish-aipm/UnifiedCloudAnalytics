-- External Storage Integration object to bring refined data from GCP in json format

CREATE or REPLACE STORAGE INTEGRATION gcp_data
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = GCS
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('gcs://userrating-refined/');  

-- Capture the Service Account Info
DESC INTEGRATION GCP_DATA;

-- Create the File Format Object
CREATE OR REPLACE FILE FORMAT json_format_data
TYPE = 'JSON';

-- Create an External Stage using parameters above
CREATE OR REPLACE STAGE gcp_stage
  URL = 'gcs://userrating-refined/'
  STORAGE_INTEGRATION = gcp_data
  FILE_FORMAT = json_format_data;

  -- Verify the access, Expected to the get list of the files on GCS
  LS @gcp_stage;


  -- Create table for raw json data stored in variant data type

  
CREATE OR REPLACE TABLE raw_data_varient (
  data VARIANT
);

-- Copy into table command to load file data to the varient data column

COPY INTO raw_data_varient
FROM @gcp_stage/SampleDatasetInJson.json
FILE_FORMAT = (FORMAT_NAME = json_format_data);

-- Confirm the data load

SELECT * FROM raw_data_varient LIMIT 10;

  -- Create the table for GCP sources datasets in respective columns
  
CREATE OR REPLACE TABLE product_estimates (
  YEAR NUMBER,
  MONTH NUMBER,
  PRODUCT STRING,
  TITLE STRING,
  BRAND STRING,
  ESTIMATED_VIEWS FLOAT,
  ESTIMATED_PURCHASES FLOAT
);

-- Now load JSON Data Using COPY INTO

COPY INTO product_estimates
FROM @gcp_stage/SampleDatasetInJson.json
FILE_FORMAT = (FORMAT_NAME = json_format_data)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;


-- Confirm the data load

SELECT * FROM product_estimates LIMIT 10;

