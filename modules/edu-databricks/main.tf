# -----------------------------------------------------------------------------
# Catalogs
resource databricks_catalog edu_raw_catalogs {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  name         = "${each.value.prefix}raw"
  comment      = "Raw data (${each.value.name} environment)"
  storage_root = var.storage_location
}

resource databricks_catalog edu_analytics_catalogs {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  name         = "${each.value.prefix}analytics"
  comment      = "Analytics data (${each.value.name} environment)"
  storage_root = var.storage_location
}


# -----------------------------------------------------------------------------
# Schemas
resource databricks_schema edu_raw_edfi3_schemas {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  name         = "edfi3"
  catalog_name = "${each.value.prefix}raw"
  comment      = "Raw data from Ed-Fi Suite 3 systems (${each.value.name} environment)"
  depends_on   = [ databricks_catalog.edu_raw_catalogs ]
}

resource databricks_schema edu_raw_util_schemas {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  name         = "util"
  catalog_name = "${each.value.prefix}raw"
  comment      = "Raw schema for holding stages (${each.value.name} environment)"
  depends_on   = [ databricks_catalog.edu_raw_catalogs ]
}


# -----------------------------------------------------------------------------
# Tables
locals {
  template_columns = [
    { name = "filename",           type = "string" },
    { name = "file_row_number",    type = "int" },
    { name = "tenant_code",        type = "string" },
    { name = "api_year",           type = "int" },
    { name = "pull_date",          type = "date" },
    { name = "pull_timestamp",     type = "timestamp_ntz" },
    { name = "name",               type = "string" },
    { name = "ods_version",        type = "string" },
    { name = "data_model_version", type = "string" },
    { name = "v",                  type = "variant" },
  ]
  mcv_columns = [
    { name = "tenant_code",    type = "string" },
    { name = "api_year",       type = "int" },
    { name = "name",           type = "string" },
    { name = "is_deletes",     type = "boolean" },
    { name = "pull_date",      type = "date" },
    { name = "pull_timestamp", type = "timestamp_ntz" },
    { name = "max_version",    type = "int" },
    { name = "is_active",      type = "boolean" },
  ]
}

resource databricks_sql_table edu_template_tables {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  name         = "_template_table"
  catalog_name = "${each.value.prefix}raw"
  schema_name  = "edfi3"
  table_type   = "MANAGED"
  warehouse_id = databricks_sql_endpoint.edu_loading_warehouses["${each.value.name}"].id
  depends_on   = [ databricks_sql_endpoint.edu_loading_warehouses, databricks_schema.edu_raw_edfi3_schemas ]

  dynamic "column" {
    for_each = local.template_columns
    content {
      name     = column.value.name
      type     = column.value.type
    }
  }
}

resource databricks_sql_table edu_descriptors_tables {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  name       = "_descriptors"
  catalog_name = "${each.value.prefix}raw"
  schema_name  = "edfi3"
  table_type   = "MANAGED"
  warehouse_id = databricks_sql_endpoint.edu_loading_warehouses["${each.value.name}"].id
  depends_on   = [ databricks_sql_endpoint.edu_loading_warehouses, databricks_schema.edu_raw_edfi3_schemas ]

  dynamic "column" {
    for_each = local.template_columns
    content {
      name     = column.value.name
      type     = column.value.type
    }
  }
}

resource databricks_sql_table edu_deletes_tables {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  name       = "_deletes"
  catalog_name = "${each.value.prefix}raw"
  schema_name  = "edfi3"
  table_type   = "MANAGED"
  warehouse_id = databricks_sql_endpoint.edu_loading_warehouses["${each.value.name}"].id
  depends_on   = [ databricks_sql_endpoint.edu_loading_warehouses, databricks_schema.edu_raw_edfi3_schemas ]

  dynamic "column" {
    for_each = local.template_columns
    content {
      name     = column.value.name
      type     = column.value.type
    }
  }
}

resource databricks_sql_table edu_meta_change_version_tables {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  name       = "_meta_change_versions"
  catalog_name = "${each.value.prefix}raw"
  schema_name  = "edfi3"
  table_type   = "MANAGED"
  warehouse_id = databricks_sql_endpoint.edu_loading_warehouses["${each.value.name}"].id
  depends_on   = [ databricks_sql_endpoint.edu_loading_warehouses, databricks_schema.edu_raw_edfi3_schemas ]

  dynamic "column" {
    for_each = local.mcv_columns
    content {
      name     = column.value.name
      type     = column.value.type
    }
  }
}


# -----------------------------------------------------------------------------
# Warehouses
resource databricks_sql_endpoint edu_loading_warehouses { #
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  name             = "loading_${each.value.name}"
  cluster_size     = "Small"
  min_num_clusters = 1
  max_num_clusters = 1
  auto_stop_mins   = 10
  enable_serverless_compute = true
}

resource databricks_sql_endpoint edu_transforming_warehouses { #
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  name             = "transforming_${each.value.name}"
  cluster_size     = "Small"
  min_num_clusters = 1
  max_num_clusters = 1
  auto_stop_mins   = 10
  enable_serverless_compute = true
}

resource databricks_sql_endpoint edu_district_ad_hoc_warehouse { #
  provider = databricks.workspace
  name             = "district_ad_hoc"
  cluster_size     = "X-Small"
  min_num_clusters = 1
  max_num_clusters = 1
  auto_stop_mins   = 10
  enable_serverless_compute = true
}


# -----------------------------------------------------------------------------
# Groups (Snowflake roles)
resource databricks_group raw_r_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  display_name          = "db_${each.value.prefix}raw_r"
  databricks_sql_access = true
  workspace_access      = true
}

resource databricks_group raw_rw_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  display_name          = "db_${each.value.prefix}raw_rw"
  databricks_sql_access = true
  workspace_access      = true
}

resource databricks_group analytics_r_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  display_name          = "db_${each.value.prefix}analytics_r"
  databricks_sql_access = true
  workspace_access      = true
}

resource databricks_group analytics_rw_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  display_name          = "db_${each.value.prefix}analytics_rw"
  databricks_sql_access = true
  workspace_access      = true
}

resource databricks_group loader_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  display_name          = "loader${each.value.suffix}"
  databricks_sql_access = true
  workspace_access      = true
}

resource databricks_group transformer_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  display_name          = "transformer${each.value.suffix}"
  databricks_sql_access = true
  workspace_access      = true
}

resource databricks_group district_analyst_role {
  provider = databricks.account
  display_name          = "district_analyst"
  databricks_sql_access = true
  workspace_access      = true
}

resource databricks_group sysadmin_role {
  provider = databricks.account
  display_name          = "sysadmin"
  databricks_sql_access = true
  workspace_access      = true
}


# -----------------------------------------------------------------------------
# Service Principals
resource databricks_service_principal edu_airflow_users { #
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  display_name          = "loader_airflow_${each.value.name}"
  databricks_sql_access = true
  workspace_access      = true
}

resource databricks_service_principal edu_dbt_users { #
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  display_name          = "transformer_dbt_${each.value.name}"
  databricks_sql_access = true
  workspace_access      = true
}


# -----------------------------------------------------------------------------
# Grants (privileges to role)
# grant usage on database raw to role db_raw_r;
resource databricks_grant usage_on_raw_to_db_raw_r { 
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  catalog    = "${each.value.prefix}raw"
  principal  = "db_${each.value.prefix}raw_r"
  privileges = [ "USE CATALOG", "USE SCHEMA", "SELECT" ]
  depends_on = [ databricks_catalog.edu_raw_catalogs, databricks_group.raw_r_roles ]
}

# grant all on database raw to role db_raw_rw;
resource databricks_grant all_on_raw_to_db_raw_rw { 
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  catalog    = "${each.value.prefix}raw"
  principal  = "db_${each.value.prefix}raw_rw"
  privileges = [ "ALL PRIVILEGES" ]
  depends_on = [ databricks_catalog.edu_raw_catalogs, databricks_group.raw_rw_roles ]
}

# grant usage on database analytics to role db_analytics_r;
resource databricks_grant usage_on_analytics_to_db_analytics_r { 
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  catalog    = "${each.value.prefix}analytics"
  principal  = "db_${each.value.prefix}analytics_r"
  privileges = [ "USE CATALOG", "USE SCHEMA", "SELECT" ]
  depends_on = [ databricks_catalog.edu_analytics_catalogs, databricks_group.analytics_r_roles ]
}

# grant all on database analytics to role db_analytics_rw;
resource databricks_grant all_on_analytics_to_db_analytics_rw { 
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  catalog    = "${each.value.prefix}analytics"
  principal  = "db_${each.value.prefix}analytics_rw"
  privileges = [ "ALL PRIVILEGES" ]
  depends_on = [ databricks_catalog.edu_analytics_catalogs, databricks_group.analytics_rw_roles ]
}


# -----------------------------------------------------------------------------
# Group memberships (role to role grants)
# loader roles:
resource databricks_group_member db_raw_rw_to_loader {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  group_id   = databricks_group.raw_rw_roles[each.value.name].id
  member_id  = databricks_group.loader_roles[each.value.name].id
  depends_on = [ databricks_group.raw_rw_roles, databricks_group.loader_roles ]
}

# transformer roles:
resource databricks_group_member db_raw_r_to_transformer {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  group_id   = databricks_group.raw_r_roles[each.value.name].id
  member_id  = databricks_group.transformer_roles[each.value.name].id
  depends_on = [ databricks_group.raw_r_roles, databricks_group.transformer_roles ]
}

resource databricks_group_member db_analytics_rw_to_transformer {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  group_id   = databricks_group.analytics_rw_roles[each.value.name].id
  member_id  = databricks_group.transformer_roles[each.value.name].id
  depends_on = [ databricks_group.analytics_rw_roles, databricks_group.transformer_roles ]
}

# -- note: transformer_dev can read from prod raw data, but can't write to prod analytics
resource databricks_group_member db_raw_r_to_transformer_dev {
  provider = databricks.account
  group_id   = databricks_group.raw_r_roles["prod"].id
  member_id  = databricks_group.transformer_roles["dev"].id
  depends_on = [ databricks_group.raw_r_roles, databricks_group.transformer_roles ]
}

# grant role db_analytics_r to role district_analyst (_only_ prod, not dev/test/other env schemas)
resource databricks_group_member db_analytics_r_to_district_analyst {
  provider = databricks.account
  group_id   = databricks_group.analytics_r_roles["prod"].id
  member_id  = databricks_group.district_analyst_role.id
  depends_on = [ databricks_group.analytics_r_roles, databricks_group.district_analyst_role ]
}

# -- grant functional roles back to sysadmin
resource databricks_group_member loader_to_sysadmin {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  group_id   = databricks_group.loader_roles[each.value.name].id
  member_id  = databricks_group.sysadmin_role.id
  depends_on = [ databricks_group.loader_roles, databricks_group.sysadmin_role ]
}

resource databricks_group_member transformer_to_sysadmin {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  group_id   = databricks_group.transformer_roles[each.value.name].id
  member_id  = databricks_group.sysadmin_role.id
  depends_on = [ databricks_group.transformer_roles, databricks_group.sysadmin_role ]
}


# -----------------------------------------------------------------------------
# Service principal group memberships (grant functional roles to users)
resource databricks_group_member loader_to_loader_airflow {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  group_id   = databricks_group.loader_roles[each.value.name].id
  member_id  = databricks_service_principal.edu_airflow_users[each.value.name].id
  depends_on = [ databricks_group.loader_roles, databricks_service_principal.edu_airflow_users ]
}

resource databricks_group_member transformer_to_transformer_dbt {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.account
  group_id   = databricks_group.transformer_roles[each.value.name].id
  member_id  = databricks_service_principal.edu_dbt_users[each.value.name].id
  depends_on = [ databricks_group.transformer_roles, databricks_service_principal.edu_dbt_users ]
}


# -----------------------------------------------------------------------------
# Workspace access grants
resource databricks_mws_permission_assignment loader_group_workspace_access {
  for_each     = { for group in databricks_group.loader_roles : group.display_name => group }
  provider     = databricks.account
  workspace_id = var.workspace_id
  principal_id = each.value.id
  permissions  = ["USER"]
  depends_on   = [ databricks_group.loader_roles ]
}

resource databricks_mws_permission_assignment transformer_group_workspace_access {
  for_each     = { for group in databricks_group.transformer_roles : group.display_name => group }
  provider     = databricks.account
  workspace_id = var.workspace_id
  principal_id = each.value.id
  permissions  = ["USER"]
  depends_on   = [ databricks_group.transformer_roles ]
}

resource databricks_mws_permission_assignment district_analyst_workspace_access {
  provider     = databricks.account
  workspace_id = var.workspace_id
  principal_id = databricks_group.district_analyst_role.id
  permissions  = ["USER"]
  depends_on   = [ databricks_group.district_analyst_role ]
}

resource databricks_mws_permission_assignment sysadmin_workspace_access {
  provider     = databricks.account
  workspace_id = var.workspace_id
  principal_id = databricks_group.sysadmin_role.id
  permissions  = ["USER"]
  depends_on   = [ databricks_group.sysadmin_role ]
}


# -----------------------------------------------------------------------------
# Warehouse usage grants
resource databricks_permissions wh_usage_to_district_analyst { #
  provider = databricks.workspace
  sql_endpoint_id = databricks_sql_endpoint.edu_district_ad_hoc_warehouse.id
  access_control {
    group_name       = "district_analyst"
    permission_level = "CAN_USE"
  }
  depends_on = [ databricks_sql_endpoint.edu_district_ad_hoc_warehouse, databricks_group.district_analyst_role ]
}

resource databricks_permissions loading_wh_usage_to_loader {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  sql_endpoint_id = databricks_sql_endpoint.edu_loading_warehouses[each.value.name].id
  access_control {
    group_name       = "loader${each.value.suffix}"
    permission_level = "CAN_USE"
  }
  depends_on = [ databricks_sql_endpoint.edu_loading_warehouses, databricks_group.loader_roles ]
}

resource databricks_permissions transforming_wh_usage_to_transformer {
  for_each = { for env in var.environments : env.name => env }
  provider = databricks.workspace
  sql_endpoint_id = databricks_sql_endpoint.edu_transforming_warehouses[each.value.name].id
  access_control {
    group_name       = "transformer${each.value.suffix}"
    permission_level = "CAN_USE"
  }
  depends_on = [ databricks_sql_endpoint.edu_transforming_warehouses, databricks_group.transformer_roles ]
}