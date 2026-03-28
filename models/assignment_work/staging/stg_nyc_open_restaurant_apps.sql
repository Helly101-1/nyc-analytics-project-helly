-- Clean and standardize NYC Open Restaurant Applications data
-- One row per application

WITH source AS (
  SELECT * FROM {{ source('raw', 'source_nyc_open_restaurant_apps') }}
),

cleaned AS (
  SELECT
    * EXCEPT (
      objectid,
      time_of_submission,
      borough,
      bulding_number,
      business_address,
      doing_business_as_dba,
      food_service_establishment,
      legal_business_name,
      restaurant_name,
      street,
      zip,
      latitude,
      longitude,
      roadway_dimensions_length,
      roadway_dimensions_width,
      sidewalk_dimensions_length,
      sidewalk_dimensions_width,
      approved_for_roadway_seating,
      approved_for_sidewalk_seating
    ),

    CAST(objectid AS STRING) AS application_id,
    CAST(time_of_submission AS TIMESTAMP) AS submitted_at,

    CAST(restaurant_name AS STRING) AS restaurant_name,
    CAST(legal_business_name AS STRING) AS legal_business_name,
    CAST(doing_business_as_dba AS STRING) AS doing_business_as_dba,
    CAST(food_service_establishment AS STRING) AS food_service_establishment,

    CAST(bulding_number AS STRING) AS building_number,
    CAST(business_address AS STRING) AS business_address,
    CAST(street AS STRING) AS street,

    CASE
      WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
      WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
      WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
      WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
      WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
      ELSE 'UNKNOWN'
    END AS borough,

    CASE
      WHEN UPPER(TRIM(CAST(zip AS STRING))) IN ('N/A', 'NA', '') THEN NULL
      WHEN LENGTH(CAST(zip AS STRING)) = 5 THEN CAST(zip AS STRING)
      WHEN LENGTH(CAST(zip AS STRING)) = 9 THEN CAST(zip AS STRING)
      WHEN LENGTH(CAST(zip AS STRING)) = 10
        AND REGEXP_CONTAINS(CAST(zip AS STRING), r'^\d{5}-\d{4}')
      THEN CAST(zip AS STRING)
      ELSE NULL
    END AS zip,

    CAST(latitude AS NUMERIC) AS latitude,
    CAST(longitude AS NUMERIC) AS longitude,

    CAST(roadway_dimensions_length AS NUMERIC) AS roadway_length,
    CAST(roadway_dimensions_width AS NUMERIC) AS roadway_width,
    CAST(sidewalk_dimensions_length AS NUMERIC) AS sidewalk_length,
    CAST(sidewalk_dimensions_width AS NUMERIC) AS sidewalk_width,

    UPPER(TRIM(CAST(approved_for_roadway_seating AS STRING))) AS approved_for_roadway_seating,
    UPPER(TRIM(CAST(approved_for_sidewalk_seating AS STRING))) AS approved_for_sidewalk_seating,

    CURRENT_TIMESTAMP() AS _stg_loaded_at

  FROM source
  WHERE objectid IS NOT NULL

  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY objectid
    ORDER BY time_of_submission DESC
  ) = 1
)

SELECT * FROM cleaned