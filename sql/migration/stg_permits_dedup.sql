WITH ranked AS (
    SELECT
        permit_id,
        property_id,
        permit_type,
        UPPER(TRIM(permit_status)) AS permit_status,
        issue_date,
        expiration_date,
        closed_date,
        estimated_cost,
        ward_id,
        community_area_id,
        UPPER(TRIM(address_line_1)) AS address_line_1,
        UPPER(TRIM(city)) AS city,
        UPPER(TRIM(state)) AS state,
        TRIM(zip_code) AS zip_code,
        source_system,
        source_updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY permit_id
            ORDER BY source_updated_at DESC, load_ts DESC
        ) AS rn
    FROM city_ops_stg.stg_permits
)
SELECT *
FROM ranked
WHERE rn = 1;
