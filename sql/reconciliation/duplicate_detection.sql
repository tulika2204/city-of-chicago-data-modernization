SELECT
    permit_id,
    COUNT(*) AS duplicate_count
FROM city_ops_stg.stg_permits
GROUP BY permit_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, permit_id;
