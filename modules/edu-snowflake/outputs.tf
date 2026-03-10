# returning all the resources created by this module allows other modules to
# depend_on or import them:
output raw_databases {
    value = snowflake_database.edu_raw_databases
}
output analytics_databases {
    value = snowflake_database.edu_analytics_databases
}
output raw_edfi3_schemas {
    value = snowflake_schema.edu_raw_edfi3_schemas
}
output raw_util_schemas {
    value = snowflake_schema.edu_raw_util_schemas
}
output loading_warehouses {
    value = snowflake_warehouse.edu_loading_warehouses
}
output transforming_warehouses {
    value = snowflake_warehouse.edu_transforming_warehouses
}
output district_ad_hoc_warehouse {
    value = snowflake_warehouse.edu_district_ad_hoc_warehouse
}
output json_file_formats {
    value = snowflake_file_format.edu_json_file_formats
}
output csv_file_formats {
    value = snowflake_file_format.edu_csv_file_formats
}
output raw_r_roles {
    value = snowflake_account_role.raw_r_roles
}
output raw_rw_roles {
    value = snowflake_account_role.raw_rw_roles
}
output analytics_r_roles {
    value = snowflake_account_role.analytics_r_roles
}
output analytics_rw_roles {
    value = snowflake_account_role.analytics_rw_roles
}
output loader_roles {
    value = snowflake_account_role.loader_roles
}
output transformer_roles {
    value = snowflake_account_role.transformer_roles
}
output district_analyst_role {
    value = snowflake_account_role.district_analyst_role
}
output airflow_users {
    value = snowflake_legacy_service_user.edu_airflow_users
}
output dbt_users {
    value = snowflake_legacy_service_user.edu_dbt_users
}