# returning all the resources created by this module allows other modules to
# depend_on or import them:
output raw_catalogs {
    value = databricks_catalog.edu_raw_catalogs
}
output analytics_catalogs {
    value = databricks_catalog.edu_analytics_catalogs
}
output raw_edfi3_schemas {
    value = databricks_schema.edu_raw_edfi3_schemas
}
output raw_util_schemas {
    value = databricks_schema.edu_raw_util_schemas
}
output loading_warehouses {
    value = databricks_sql_endpoint.edu_loading_warehouses
}
output transforming_warehouses {
    value = databricks_sql_endpoint.edu_transforming_warehouses
}
output district_analyst_warehouse {
    value = databricks_sql_endpoint.edu_district_analyst_warehouse
}
output raw_r_roles {
    value = databricks_group.raw_r_roles
}
output raw_rw_roles {
    value = databricks_group.raw_rw_roles
}
output analytics_r_roles {
    value = databricks_group.analytics_r_roles
}
output analytics_rw_roles {
    value = databricks_group.analytics_rw_roles
}
output loader_roles {
    value = databricks_group.loader_roles
}
output transformer_roles {
    value = databricks_group.transformer_roles
}
output district_analyst_role {
    value = databricks_group.district_analyst_role
}
output sysadmin_role {
    value = databricks_group.sysadmin_role
}
output airflow_users {
    value = databricks_service_principal.edu_airflow_users
}
output dbt_users {
    value = databricks_service_principal.edu_dbt_users
}