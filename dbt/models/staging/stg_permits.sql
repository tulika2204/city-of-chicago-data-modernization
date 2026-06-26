select
    permit_id,
    property_id,
    upper(trim(permit_type)) as permit_type,
    upper(trim(permit_status)) as permit_status,
    issue_date,
    expiration_date,
    closed_date,
    estimated_cost,
    ward_id,
    community_area_id,
    upper(trim(address_line_1)) as address_line_1,
    upper(trim(city)) as city,
    upper(trim(state)) as state,
    trim(zip_code) as zip_code,
    source_updated_at
from {{ source('city_ops_stg', 'stg_permits') }}
