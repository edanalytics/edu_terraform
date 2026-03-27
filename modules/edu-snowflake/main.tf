# -----------------------------------------------------------------------------
# Databases
resource snowflake_database edu_raw_databases {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name     = upper("${each.value.prefix}raw")
  comment  = "Raw data (${each.value.name} environment)"
  data_retention_time_in_days = 1
}

resource snowflake_database edu_analytics_databases {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name     = upper("${each.value.prefix}analytics")
  comment  = "Analytics data (${each.value.name} environment)"
  data_retention_time_in_days = 1
}



# -----------------------------------------------------------------------------
# Schemas
resource snowflake_schema edu_raw_edfi3_schemas {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name       = upper("edfi3")
  database   = upper("${each.value.prefix}raw")
  comment    = "Raw data from Ed-Fi Suite 3 systems (${each.value.name} environment)"
  depends_on = [ snowflake_database.edu_raw_databases ]
}

resource snowflake_schema edu_raw_util_schemas {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name       = upper("util")
  database   = upper("${each.value.prefix}raw")
  comment    = "Raw schema for holding stages (${each.value.name} environment)"
  depends_on = [ snowflake_database.edu_raw_databases ]
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

resource snowflake_table edu_template_tables {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name       = upper("_template_table")
  database   = upper("${each.value.prefix}raw")
  schema     = upper("edfi3")
  depends_on = [ snowflake_schema.edu_raw_edfi3_schemas ]

  dynamic "column" {
    for_each = local.template_columns
    content {
      name     = upper(column.value.name)
      type     = column.value.type
    }
  }
}

resource snowflake_table edu_descriptors_tables {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name       = upper("_descriptors")
  database   = upper("${each.value.prefix}raw")
  schema     = upper("edfi3")
  depends_on = [ snowflake_schema.edu_raw_edfi3_schemas ]

  dynamic "column" {
    for_each = local.template_columns
    content {
      name     = upper(column.value.name)
      type     = column.value.type
    }
  }
}

resource snowflake_table edu_deletes_tables {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name       = upper("_deletes")
  database   = upper("${each.value.prefix}raw")
  schema     = upper("edfi3")
  depends_on = [ snowflake_schema.edu_raw_edfi3_schemas ]

  dynamic "column" {
    for_each = local.template_columns
    content {
      name     = upper(column.value.name)
      type     = column.value.type
    }
  }
}

resource snowflake_table edu_meta_change_version_tables {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name       = upper("_meta_change_versions")
  database   = upper("${each.value.prefix}raw")
  schema     = upper("edfi3")
  depends_on = [ snowflake_schema.edu_raw_edfi3_schemas ]

  dynamic "column" {
    for_each = local.mcv_columns
    content {
      name     = upper(column.value.name)
      type     = column.value.type
    }
  }
}



# -----------------------------------------------------------------------------
# Warehouses
resource snowflake_warehouse edu_loading_warehouses {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name                = upper("loading_${each.value.name}")
  comment             = "Loading raw data (${each.value.name} environment)"
  warehouse_size      = "${each.value.name}" == "test" ? "xsmall" : "small"
  auto_suspend        = 60
  auto_resume         = true
  initially_suspended = true
  statement_timeout_in_seconds = 14400 # 4 hours... is this a good default? should it be configurable?
}
resource snowflake_warehouse edu_transforming_warehouses {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name                = upper("transforming_${each.value.name}")
  comment             = "Transforming raw data (${each.value.name} environment)"
  warehouse_size      = "medium"
  auto_suspend        = 60
  auto_resume         = true
  initially_suspended = true
  statement_timeout_in_seconds = 14400 # 4 hours... is this a good default? should it be configurable?
}
resource snowflake_warehouse edu_district_ad_hoc_warehouse {
  provider = snowflake.sysadmin
  name                = upper("district_ad_hoc")
  comment             = "District Analyst Queries"
  warehouse_size      = "small"
  auto_suspend        = 60
  auto_resume         = true
  initially_suspended = true
  statement_timeout_in_seconds = 14400 # 4 hours... is this a good default? should it be configurable?
}



# -----------------------------------------------------------------------------
# File formats
resource snowflake_file_format edu_json_file_formats {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name               = upper("json_default")
  database           = upper("${each.value.prefix}raw")
  schema             = upper("public")
  format_type        = "json"
  compression        = "auto"
  enable_octal       = false
  allow_duplicate    = false
  strip_outer_array  = false
  strip_null_values  = true
  ignore_utf8_errors = false
  depends_on         = [ snowflake_database.edu_raw_databases ]
}
resource snowflake_file_format edu_csv_file_formats {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.sysadmin
  name               = upper("csv_default")
  database           = upper("${each.value.prefix}raw")
  schema             = upper("public")
  format_type        = "CSV"
  skip_header        = 1
  field_optionally_enclosed_by = "\\\""
  depends_on         = [ snowflake_database.edu_raw_databases ]
}



# -----------------------------------------------------------------------------
# Roles
resource snowflake_account_role raw_r_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.securityadmin
  name     = upper("db_${each.value.prefix}raw_r")
  comment  = "Access role: read on all schemas and tables in raw db (${each.value.name} environment)"
}
resource snowflake_account_role raw_rw_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.securityadmin
  name     = upper("db_${each.value.prefix}raw_rw")
  comment  = "Access role: write on all schemas and tables in raw db (${each.value.name} environment)"
}
resource snowflake_account_role analytics_r_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.securityadmin
  name     = upper("db_${each.value.prefix}analytics_r")
  comment  = "Access role: read on all schemas and tables in analytics (${each.value.name} environment)"
}
resource snowflake_account_role analytics_rw_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.securityadmin
  name     = upper("db_${each.value.prefix}analytics_rw")
  comment  = "Access role: write on all schemas and tables in analytics (${each.value.name} environment)"
}
resource snowflake_account_role loader_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.securityadmin
  name     = upper("loader_${each.value.name}")
  comment  = "Functional role: Raw data loading (${each.value.name} environment)"
}
resource snowflake_account_role transformer_roles {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.securityadmin
  name     = upper("transformer_${each.value.name}")
  comment  = "Functional role: dbt (${each.value.name} environment)"
}
resource snowflake_account_role district_analyst_role {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.securityadmin
  name     = upper("${each.value.prefix}district_analyst")
  comment  = "Functional role: District Analysts reading analytics data"
}



# -----------------------------------------------------------------------------
# Users
resource snowflake_legacy_service_user edu_airflow_users {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.securityadmin
  name              = upper("loader_airflow_${each.value.name}")
  comment           = "Airflow service user (${each.value.name} environment)"
  default_warehouse = upper("loading_${each.value.name}")
  default_namespace = upper("${each.value.prefix}raw")
  default_role      = upper("loader_${each.value.name}")
  depends_on        = [ snowflake_account_role.loader_roles, snowflake_warehouse.edu_loading_warehouses, snowflake_schema.edu_raw_edfi3_schemas ]
}
resource snowflake_legacy_service_user edu_dbt_users {
  for_each = { for env in var.environments : env.name => env }
  provider = snowflake.securityadmin
  name              = upper("transformer_dbt_${each.value.name}")
  comment           = "dbt service user (${each.value.name} environment)"
  default_warehouse = upper("transforming_${each.value.name}")
  default_namespace = upper("${each.value.prefix}analytics")
  default_role      = upper("transformer_${each.value.name}")
  depends_on        = [ snowflake_account_role.transformer_roles, snowflake_warehouse.edu_transforming_warehouses, snowflake_schema.edu_raw_edfi3_schemas ]
}

# -----------------------------------------------------------------------------
# Grants (privileges to role)

# grant role db_analytics_r to role district_analyst;
resource "snowflake_grant_account_role" "db_analytics_r_to_district_analyst" {
  for_each = { for env in var.environments : env.name => env }
  provider         = snowflake.securityadmin
  role_name        = upper("db_${each.value.prefix}analytics_r")
  parent_role_name = upper("${each.value.prefix}district_analyst")
  depends_on       = [ snowflake_account_role.district_analyst_role, snowflake_account_role.analytics_r_roles ]
}
# grant usage, monitor on warehouse district_analyst to role district_analyst;
resource "snowflake_grant_privileges_to_account_role" "wh_usage_to_security_manager" {
  for_each = { for env in var.environments : env.name => env }
  provider          = snowflake.securityadmin
  privileges        = ["USAGE", "MONITOR"]
  account_role_name = upper("${each.value.prefix}district_analyst")
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = upper("district_ad_hoc")
  }
  depends_on        = [ snowflake_warehouse.edu_district_ad_hoc_warehouse, snowflake_account_role.district_analyst_role ]
}

# grant usage on database raw to role db_raw_r;
resource "snowflake_grant_privileges_to_account_role" "usage_on_raw_to_db_raw_r" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  privileges        = ["USAGE"]
  account_role_name = upper("db_${each.value.prefix}raw_r")
  on_account_object {
    object_type = "DATABASE"
    object_name = upper("${each.value.prefix}raw")
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_account_role.raw_r_roles ]
}
# grant usage, create schema on database raw to role db_raw_rw;
resource "snowflake_grant_privileges_to_account_role" "usage_create_schema_on_raw_to_db_raw_rw" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  privileges        = ["USAGE", "CREATE SCHEMA"]
  account_role_name = upper("db_${each.value.prefix}raw_rw")
  on_account_object {
    object_type = "DATABASE"
    object_name = upper("${each.value.prefix}raw")
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_account_role.raw_rw_roles ]
}
# grant usage on database analytics to role db_analytics_r;
resource "snowflake_grant_privileges_to_account_role" "usage_on_analytics_to_db_analytics_r" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  privileges        = ["USAGE"]
  account_role_name = upper("db_${each.value.prefix}analytics_r")
  on_account_object {
    object_type = "DATABASE"
    object_name = upper("${each.value.prefix}analytics")
  }
  depends_on        = [ snowflake_database.edu_analytics_databases, snowflake_account_role.analytics_r_roles ]
}
# grant usage, create schema on database analytics to role db_analytics_rw;
resource "snowflake_grant_privileges_to_account_role" "usage_create_schema_on_analytics_to_db_analytics_rw" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  privileges        = ["USAGE", "CREATE SCHEMA"]
  account_role_name = upper("db_${each.value.prefix}analytics_rw")
  on_account_object {
    object_type = "DATABASE"
    object_name = upper("${each.value.prefix}analytics")
  }
  depends_on        = [ snowflake_database.edu_analytics_databases, snowflake_account_role.analytics_rw_roles ]
}
# grant usage on all schemas in database raw to role db_raw_r;
resource "snowflake_grant_privileges_to_account_role" "usage_on_all_schemas_raw_to_db_raw_r" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  privileges        = ["USAGE"]
  account_role_name = upper("db_${each.value.prefix}raw_r")
  on_schema {
    all_schemas_in_database = upper("${each.value.prefix}raw")
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_account_role.raw_r_roles ]
}
# grant usage on all schemas in database raw to role db_raw_r;
resource "snowflake_grant_privileges_to_account_role" "usage_on_future_raw_to_db_raw_r" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  privileges        = ["USAGE"]
  account_role_name = upper("db_${each.value.prefix}raw_r")
  on_schema {
    future_schemas_in_database = upper("${each.value.prefix}raw")
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_account_role.raw_r_roles ]
}
# grant usage on all schemas in database analytics to role db_analytics_r;
resource "snowflake_grant_privileges_to_account_role" "usage_on_all_schemas_analytics_to_db_analytics_r" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  privileges        = ["USAGE"]
  account_role_name = upper("db_${each.value.prefix}analytics_r")
  on_schema {
    all_schemas_in_database = upper("${each.value.prefix}analytics")
  }
  depends_on        = [ snowflake_database.edu_analytics_databases, snowflake_account_role.analytics_r_roles ]
}
# grant usage on future schemas in database analytics to role db_analytics_r;
resource "snowflake_grant_privileges_to_account_role" "usage_on_future_analytics_to_db_analytics_r" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  privileges        = ["USAGE"]
  account_role_name = upper("db_${each.value.prefix}analytics_r")
  on_schema {
    future_schemas_in_database = upper("${each.value.prefix}analytics")
  }
  depends_on        = [ snowflake_database.edu_analytics_databases, snowflake_account_role.analytics_r_roles ]
}

# -- all for rw roles
# -- todo: actually all, or do we want to distinguish between rw and admin?
# -- todo: what about snapshot permissions? just let dbt handle?
# grant all on all schemas in database raw to role db_raw_rw;
resource "snowflake_grant_privileges_to_account_role" "all_on_all_schemas_raw_to_db_raw_rw" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  all_privileges    = true
  account_role_name = upper("db_${each.value.prefix}raw_rw")
  on_schema {
    all_schemas_in_database = upper("${each.value.prefix}raw")
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_account_role.raw_rw_roles ]
}
# grant usage on all schemas in database raw to role db_raw_r;
resource "snowflake_grant_privileges_to_account_role" "all_on_future_raw_to_db_raw_rw" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  all_privileges    = true
  account_role_name = upper("db_${each.value.prefix}raw_rw")
  on_schema {
    future_schemas_in_database = upper("${each.value.prefix}raw")
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_account_role.raw_rw_roles ]
}
# grant usage on all schemas in database analytics to role db_analytics_r;
resource "snowflake_grant_privileges_to_account_role" "all_on_all_schemas_analytics_to_db_analytics_rw" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  all_privileges    = true
  account_role_name = upper("db_${each.value.prefix}analytics_rw")
  on_schema {
    all_schemas_in_database = upper("${each.value.prefix}analytics")
  }
  depends_on        = [ snowflake_database.edu_analytics_databases, snowflake_account_role.analytics_rw_roles ]
}
# grant usage on future schemas in database analytics to role db_analytics_r;
resource "snowflake_grant_privileges_to_account_role" "all_on_future_analytics_to_db_analytics_rw" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  all_privileges    = true
  account_role_name = upper("db_${each.value.prefix}analytics_rw")
  on_schema {
    future_schemas_in_database = upper("${each.value.prefix}analytics")
  }
  depends_on        = [ snowflake_database.edu_analytics_databases, snowflake_account_role.analytics_rw_roles ]
}




# READ ALL grants
resource "snowflake_grant_privileges_to_account_role" "read_all_grants" {
  provider          = snowflake.securityadmin
  for_each = {
    for tup in setproduct(
      tolist([ for env in var.environments : env.prefix ]),
      ["raw", "analytics"],
      ["TABLES", "VIEWS"]
    ) : join("-", tup) => {
      "prefix"   = tup[0]
      "database" = tup[1]
      "object"   = tup[2]
    }
  }
  privileges        = ["SELECT"]
  account_role_name = upper("db_${each.value.prefix}${each.value.database}_r")
  on_schema_object {
    all {
      object_type_plural = "${each.value.object}"
      in_database        = upper("${each.value.prefix}${each.value.database}")
    }
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_database.edu_analytics_databases, snowflake_account_role.raw_r_roles, snowflake_account_role.analytics_r_roles ]
}
# READ FUTURE grants
resource "snowflake_grant_privileges_to_account_role" "read_future_grants" {
  provider          = snowflake.securityadmin
  for_each = {
    for tup in setproduct(
      tolist([ for env in var.environments : env.prefix ]),
      ["raw", "analytics"],
      ["TABLES", "VIEWS"]
    ) : join("-", tup) => {
      "prefix"   = tup[0]
      "database" = tup[1]
      "object"   = tup[2]
    }
  }
  privileges        = ["SELECT"]
  account_role_name = upper("db_${each.value.prefix}${each.value.database}_r")
  on_schema_object {
    future {
      object_type_plural = "${each.value.object}"
      in_database        = upper("${each.value.prefix}${each.value.database}")
    }
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_database.edu_analytics_databases, snowflake_account_role.raw_r_roles, snowflake_account_role.analytics_r_roles ]
}
# WRITE ALL grants
resource "snowflake_grant_privileges_to_account_role" "write_all_grants" {
  provider          = snowflake.securityadmin
  for_each = {
    for tup in setproduct(
      tolist([ for env in var.environments : env.prefix ]),
      ["raw", "analytics"],
      ["TABLES", "VIEWS"]
    ) : join("-", tup) => {
      "prefix"   = tup[0]
      "database" = tup[1]
      "object"   = tup[2]
    }
  }
  all_privileges    = true
  account_role_name = upper("db_${each.value.prefix}${each.value.database}_rw")
  on_schema_object {
    all {
      object_type_plural = "${each.value.object}"
      in_database        = upper("${each.value.prefix}${each.value.database}")
    }
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_database.edu_analytics_databases, snowflake_account_role.raw_rw_roles, snowflake_account_role.analytics_rw_roles ]
}
# WRITE FUTURE grants
resource "snowflake_grant_privileges_to_account_role" "write_future_grants" {
  provider          = snowflake.securityadmin
  for_each = {
    for tup in setproduct(
      tolist([ for env in var.environments : env.prefix ]),
      ["raw", "analytics"],
      ["TABLES", "VIEWS"]
    ) : join("-", tup) => {
      "prefix"   = tup[0]
      "database" = tup[1]
      "object"   = tup[2]
    }
  }
  all_privileges    = true
  account_role_name = upper("db_${each.value.prefix}${each.value.database}_rw")
  on_schema_object {
    future {
      object_type_plural = "${each.value.object}"
      in_database        = upper("${each.value.prefix}${each.value.database}")
    }
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_database.edu_analytics_databases, snowflake_account_role.raw_rw_roles, snowflake_account_role.analytics_rw_roles ]
}

# USAGE on ALL STAGES / FILE FORMATS grants
resource "snowflake_grant_privileges_to_account_role" "usage_all_stages_file_formats_grants" {
  provider          = snowflake.securityadmin
  for_each = {
    for tup in setproduct(
      tolist([ for env in var.environments : env.prefix ]),
      ["r", "rw"],
      ["STAGES", "FILE FORMATS"]
    ) : join("-", tup) => {
      "prefix" = tup[0]
      "mode"   = tup[1]
      "object" = tup[2]
    }
  }
  privileges        = ["USAGE"]
  account_role_name = upper("db_${each.value.prefix}raw_${each.value.mode}")
  on_schema_object {
    all {
      object_type_plural = "${each.value.object}"
      in_database        = upper("${each.value.prefix}raw")
    }
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_database.edu_analytics_databases, snowflake_account_role.raw_r_roles, snowflake_account_role.analytics_r_roles ]
}
# USAGE on FUTURE STAGES / FILE FORMATS grants
resource "snowflake_grant_privileges_to_account_role" "usage_future_stages_file_formats_grants" {
  provider          = snowflake.securityadmin
  for_each = {
    for tup in setproduct(
      tolist([ for env in var.environments : env.prefix ]),
      ["r", "rw"],
      ["STAGES", "FILE FORMATS"]
    ) : join("-", tup) => {
      "prefix" = tup[0]
      "mode"   = tup[1]
      "object" = tup[2]
    }
  }
  privileges        = ["USAGE"]
  account_role_name = upper("db_${each.value.prefix}raw_${each.value.mode}")
  on_schema_object {
    future {
      object_type_plural = "${each.value.object}"
      in_database        = upper("${each.value.prefix}raw")
    }
  }
  depends_on        = [ snowflake_database.edu_raw_databases, snowflake_database.edu_analytics_databases, snowflake_account_role.raw_r_roles, snowflake_account_role.analytics_r_roles ]
}

# -----------------------------------------------------------------------------
# Grants (role to role)

# loader roles:
resource "snowflake_grant_account_role" "db_raw_rw_to_loader" {
  provider         = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  role_name        = upper("db_${each.value.prefix}raw_rw")
  parent_role_name = upper("loader${each.value.suffix}")
  depends_on       = [ snowflake_account_role.raw_rw_roles, snowflake_account_role.loader_roles ]
}
# transformer roles:
resource "snowflake_grant_account_role" "db_raw_r_to_transformer" {
  provider         = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  role_name        = upper("db_${each.value.prefix}raw_r")
  parent_role_name = upper("transformer${each.value.suffix}")
  depends_on       = [ snowflake_account_role.raw_r_roles, snowflake_account_role.transformer_roles ]
}
resource "snowflake_grant_account_role" "db_analytics_rw_to_transformer" {
  provider         = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  role_name        = upper("db_${each.value.prefix}analytics_rw")
  parent_role_name = upper("transformer${each.value.suffix}")
  depends_on       = [ snowflake_account_role.raw_rw_roles, snowflake_account_role.transformer_roles ]
}
# -- note: transformer_dev can read from prod raw data, but can't write to prod analytics
resource "snowflake_grant_account_role" "db_raw_r_to_transformer_dev" {
  provider         = snowflake.securityadmin
  role_name        = upper("db_raw_r")
  parent_role_name = upper("transformer_dev")
  depends_on       = [ snowflake_account_role.raw_r_roles, snowflake_account_role.transformer_roles ]
}

# -- grant functional roles back to sysadmin
resource "snowflake_grant_account_role" "loader_to_sysadmin" {
  provider         = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  role_name        = upper("loader${each.value.suffix}")
  parent_role_name = upper("sysadmin")
  depends_on       = [ snowflake_account_role.loader_roles ]
}
resource "snowflake_grant_account_role" "transformer_to_sysadmin" {
  provider         = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  role_name        = upper("transformer${each.value.suffix}")
  parent_role_name = upper("sysadmin")
  depends_on       = [ snowflake_account_role.transformer_roles ]
}

# -- grant functional roles to users
resource "snowflake_grant_account_role" "loader_to_loader_airflow" {
  provider         = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  role_name        = upper("loader${each.value.suffix}")
  user_name        = upper("loader_airflow${each.value.suffix}")
  depends_on       = [ snowflake_account_role.loader_roles, snowflake_legacy_service_user.edu_airflow_users ]
}
resource "snowflake_grant_account_role" "transformer_to_transformer_dbt" {
  provider         = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  role_name        = upper("transformer${each.value.suffix}")
  user_name        = upper("transformer_dbt${each.value.suffix}")
  depends_on       = [ snowflake_account_role.transformer_roles, snowflake_legacy_service_user.edu_dbt_users ]
}

# -- Warehouse grants
resource "snowflake_grant_privileges_to_account_role" "loading_wh_usage_to_loader" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  privileges        = ["USAGE"]
  account_role_name = upper("loader${each.value.suffix}")
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = upper("loading${each.value.suffix}")
  }
  depends_on        = [ snowflake_warehouse.edu_loading_warehouses, snowflake_account_role.loader_roles ]
}
resource "snowflake_grant_privileges_to_account_role" "transforming_wh_usage_to_transformer" {
  provider          = snowflake.securityadmin
  for_each = { for env in var.environments : env.name => env }
  privileges        = ["USAGE"]
  account_role_name = upper("transformer${each.value.suffix}")
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = upper("transforming${each.value.suffix}")
  }
  depends_on        = [ snowflake_warehouse.edu_transforming_warehouses, snowflake_account_role.transformer_roles ]
}


# # How to run arbitrary SQL from Terraform! (hopefully won't need this):
# resource "snowflake_sql_script" "clone_table_script" {
#   database = "your_database_name"
#   schema   = "your_schema_name"
#   # This SQL statement creates a new table "target_table" with the structure and data of "source_table".
#   # To clone only the structure (no data), you can use 'CREATE TABLE target_table LIKE source_table' in a SQL statement,
#   # however 'CLONE' is the preferred Snowflake method for zero-copy operations.
#   # Note: The snowflake_sql_script resource might have limitations regarding state tracking for CLONE operations.
#   # A simpler approach is to use the SQL below to only copy structure.
#   statement = <<-EOF
#     CREATE OR REPLACE TABLE your_database_name.your_schema_name.target_table
#     LIKE your_database_name.your_schema_name.source_table;
#   EOF
# }
