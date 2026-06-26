SELECT
    'fact_permits_without_dim_property' AS validation_name,
    COUNT(*) AS orphan_count
FROM city_ops.fact_permits f
LEFT JOIN city_ops.dim_property d
    ON f.property_sk = d.property_sk
WHERE d.property_sk IS NULL

UNION ALL

SELECT
    'fact_inspections_without_permit' AS validation_name,
    COUNT(*) AS orphan_count
FROM city_ops.fact_inspections i
LEFT JOIN city_ops.fact_permits p
    ON i.permit_id = p.permit_id
WHERE p.permit_id IS NULL

UNION ALL

SELECT
    '311_requests_without_geography' AS validation_name,
    COUNT(*) AS orphan_count
FROM city_ops_stg.stg_311_requests sr
WHERE sr.community_area_id IS NULL
   OR sr.ward_id IS NULL;
