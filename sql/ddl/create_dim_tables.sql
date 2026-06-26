CREATE SCHEMA IF NOT EXISTS city_ops;

CREATE TABLE IF NOT EXISTS city_ops.dim_property (
    property_sk           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    property_id           VARCHAR(100),
    address_line_1        VARCHAR(255),
    city                  VARCHAR(100),
    state                 VARCHAR(50),
    zip_code              VARCHAR(20),
    ward_id               INTEGER,
    community_area_id     INTEGER,
    record_hash           VARCHAR(64),
    valid_from            TIMESTAMP,
    valid_to              TIMESTAMP,
    is_current            BOOLEAN,
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS city_ops.dim_community_area (
    community_area_id     INTEGER PRIMARY KEY,
    community_area_name   VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS city_ops.dim_ward (
    ward_id               INTEGER PRIMARY KEY,
    ward_name             VARCHAR(255)
);
