SELECT
    service_request_id,
    UPPER(TRIM(request_type)) AS request_type,
    INITCAP(TRIM(request_status)) AS request_status,
    request_created_date,
    request_closed_date,
    ward_id,
    community_area_id,
    UPPER(TRIM(address_line_1)) AS address_line_1,
    UPPER(TRIM(city)) AS city,
    UPPER(TRIM(state)) AS state,
    LPAD(REGEXP_REPLACE(zip_code, '[^0-9]', ''), 5, '0') AS zip_code,
    source_system,
    source_updated_at
FROM city_ops_stg.stg_311_requests;
