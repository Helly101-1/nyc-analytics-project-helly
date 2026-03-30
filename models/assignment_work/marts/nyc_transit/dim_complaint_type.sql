-- Complaint type dimension for 311 DOT service requests

WITH complaint_types AS (
   SELECT DISTINCT
       complaint_type,
       descriptor,
       CAST(NULL AS STRING) AS complaint_category
   FROM {{ ref('stg_nyc_311_dot') }}
   WHERE complaint_type IS NOT NULL
),

complaint_dimension AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key([
           'complaint_type',
           'descriptor'
       ]) }} AS complaint_type_key,
       complaint_type,
       descriptor,
       complaint_category
   FROM complaint_types
)

SELECT * FROM complaint_dimension