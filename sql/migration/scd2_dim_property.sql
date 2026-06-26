WITH source_current AS (
    SELECT
        property_id,
        UPPER(TRIM(address_line_1)) AS address_line_1,
        UPPER(TRIM(city)) AS city,
        UPPER(TRIM(state)) AS state,
        TRIM(zip_code) AS zip_code,
        ward_id,
        community_area_id,
        MD5(
            COALESCE(property_id, '') || '|' ||
            COALESCE(UPPER(TRIM(address_line_1)), '') || '|' ||
            COALESCE(UPPER(TRIM(city)), '') || '|' ||
            COALESCE(UPPER(TRIM(state)), '') || '|' ||
            COALESCE(TRIM(zip_code), '') || '|' ||
            COALESCE(CAST(ward_id AS VARCHAR), '') || '|' ||
            COALESCE(CAST(community_area_id AS VARCHAR), '')
        ) AS record_hash
    FROM city_ops_stg.stg_permits
    WHERE property_id IS NOT NULL
),
current_dim AS (
    SELECT *
    FROM city_ops.dim_property
    WHERE is_current = TRUE
),
changes AS (
    SELECT
        s.*
    FROM source_current s
    LEFT JOIN current_dim d
        ON s.property_id = d.property_id
    WHERE d.property_id IS NULL
       OR s.record_hash <> d.record_hash
)
UPDATE city_ops.dim_property d
SET
    valid_to = CURRENT_TIMESTAMP,
    is_current = FALSE,
    updated_at = CURRENT_TIMESTAMP
FROM changes c
WHERE d.property_id = c.property_id
  AND d.is_current = TRUE;

INSERT INTO city_ops.dim_property (
    property_id,
    address_line_1,
    city,
    state,
    zip_code,
    ward_id,
    community_area_id,
    record_hash,
    valid_from,
    valid_to,
    is_current
)
SELECT
    property_id,
    address_line_1,
    city,
    state,
    zip_code,
    ward_id,
    community_area_id,
    record_hash,
    CURRENT_TIMESTAMP,
    TIMESTAMP '9999-12-31 00:00:00',
    TRUE
FROM changes;
