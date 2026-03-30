-- Restaurant dimension for open restaurant applications
{{ config(
    materialized='table',
    schema='nyc_transit_restaurants_marts'
) }}
WITH restaurants AS (
   SELECT DISTINCT
       restaurant_name,
       legal_business_name,
       doing_business_as_dba,
       food_service_establishment,
       legal_business_name AS legal_business_address,
       latitude,
       longitude
   FROM {{ ref('stg_nyc_open_restaurant_apps') }}
   WHERE restaurant_name IS NOT NULL
),

restaurant_dimension AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key([
           'restaurant_name',
           'legal_business_name'
       ]) }} AS restaurant_key,
       restaurant_name,
       legal_business_name,
       doing_business_as_dba,
       food_service_establishment,
       legal_business_address,
       latitude,
       longitude
   FROM restaurants
)

SELECT * FROM restaurant_dimension