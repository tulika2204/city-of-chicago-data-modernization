MERGE INTO city_ops.fact_permits AS target
USING (
    SELECT
        p.permit_id,
        d.property_sk,
        p.permit_type,
        p.permit_status,
        p.issue_date,
        p.expiration_date,
        p.closed_date,
        p.estimated_cost,
        p.ward_id,
        p.community_area_id,
        MD5(
            COALESCE(p.permit_id, '') || '|' ||
            COALESCE(p.permit_type, '') || '|' ||
            COALESCE(p.permit_status, '') || '|' ||
            COALESCE(CAST(p.issue_date AS VARCHAR), '') || '|' ||
            COALESCE(CAST(p.closed_date AS VARCHAR), '')
        ) AS record_hash
    FROM city_ops_stg.stg_permits p
    LEFT JOIN city_ops.dim_property d
        ON p.property_id = d.property_id
       AND d.is_current = TRUE
) AS source
ON target.permit_id = source.permit_id
WHEN MATCHED AND target.record_hash <> source.record_hash THEN
    UPDATE SET
        property_sk = source.property_sk,
        permit_type = source.permit_type,
        permit_status = source.permit_status,
        issue_date = source.issue_date,
        expiration_date = source.expiration_date,
        closed_date = source.closed_date,
        estimated_cost = source.estimated_cost,
        ward_id = source.ward_id,
        community_area_id = source.community_area_id,
        record_hash = source.record_hash,
        updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
    INSERT (
        permit_id,
        property_sk,
        permit_type,
        permit_status,
        issue_date,
        expiration_date,
        closed_date,
        estimated_cost,
        ward_id,
        community_area_id,
        record_hash
    )
    VALUES (
        source.permit_id,
        source.property_sk,
        source.permit_type,
        source.permit_status,
        source.issue_date,
        source.expiration_date,
        source.closed_date,
        source.estimated_cost,
        source.ward_id,
        source.community_area_id,
        source.record_hash
    );
