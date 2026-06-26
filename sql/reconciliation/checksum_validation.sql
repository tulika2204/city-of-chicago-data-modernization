WITH source_hash AS (
    SELECT
        MD5(
            STRING_AGG(
                COALESCE(permit_id, '') || '|' ||
                COALESCE(permit_status, '') || '|' ||
                COALESCE(CAST(issue_date AS VARCHAR), ''),
                '||'
                ORDER BY permit_id
            )
        ) AS source_checksum
    FROM city_ops_stg.stg_permits
),
target_hash AS (
    SELECT
        MD5(
            STRING_AGG(
                COALESCE(permit_id, '') || '|' ||
                COALESCE(permit_status, '') || '|' ||
                COALESCE(CAST(issue_date AS VARCHAR), ''),
                '||'
                ORDER BY permit_id
            )
        ) AS target_checksum
    FROM city_ops.fact_permits
)
SELECT
    s.source_checksum,
    t.target_checksum,
    CASE
        WHEN s.source_checksum = t.target_checksum THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM source_hash s
CROSS JOIN target_hash t;
