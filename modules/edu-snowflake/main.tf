terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.36.0"
      configuration_aliases = [ snowflake.sysadmin, snowflake.securityadmin, snowflake.useradmin ]
    }
  }
  required_version = ">= 1.2.0"
}

provider snowflake {
  alias  = "sysadmin"
  role = "sysadmin"
}

provider snowflake {
  alias  = "useradmin"
  role = "useradmin"
}

provider snowflake {
  alias  = "securityadmin"
  role = "securityadmin"
}


# -----------------------------------------------------------------------------
# Databases
resource snowflake_database databases {
  count                       = length(var.databases)
  name                        = var.databases[count.index].name
  comment                     = var.databases[count.index].comment
  data_retention_time_in_days = 1
}

# -----------------------------------------------------------------------------
# Schemas
resource snowflake_schema schemas {
  count      = length(var.schemas)
  name       = var.schemas[count.index].name
  database   = var.schemas[count.index].database
  comment    = var.schemas[count.index].comment
  depends_on = [ snowflake_database.databases ]
}

# -----------------------------------------------------------------------------
# Tables
module tables_template {
  source               = "./tables/template"

  tables               = var.tables_template
  depends_on_databases = snowflake_database.databases
  depends_on_schemas   = snowflake_schema.schemas
}
module tables_change_version {
  source               = "./tables/change-version"

  tables               = var.tables_change_version
  depends_on_databases = snowflake_database.databases
  depends_on_schemas   = snowflake_schema.schemas
}

# -----------------------------------------------------------------------------
# Shares


# -----------------------------------------------------------------------------
# File formats
resource snowflake_file_format file_formats {
  count              = length(var.file_formats)
  name               = var.file_formats[count.index].name
  database           = var.file_formats[count.index].database
  schema             = "${upper(var.file_formats[count.index].schema)}"
  format_type        = "${upper(var.file_formats[count.index].format_type)}"
  binary_format      = "${upper(var.file_formats[count.index].binary_format)}"
  compression        = var.file_formats[count.index].compression
  enable_octal       = var.file_formats[count.index].enable_octal
  allow_duplicate    = var.file_formats[count.index].allow_duplicate
  strip_outer_array  = var.file_formats[count.index].strip_outer_array
  strip_null_values  = var.file_formats[count.index].strip_null_values
  ignore_utf8_errors = var.file_formats[count.index].ignore_utf8_errors
  depends_on         = [ snowflake_database.databases, snowflake_schema.schemas ]
}

# -----------------------------------------------------------------------------
# Warehouses
resource snowflake_warehouse warehouses {
  count               = length(var.warehouses)
  name                = var.warehouses[count.index].name
  comment             = var.warehouses[count.index].comment
  warehouse_size      = var.warehouses[count.index].size
  auto_suspend        = var.warehouses[count.index].auto_suspend
  auto_resume         = var.warehouses[count.index].auto_resume
  initially_suspended = var.warehouses[count.index].initially_suspended
}

# -----------------------------------------------------------------------------
# Roles
# (must be a module so we can force use of `useradmin` role by provider)
module roles {
  source = "./roles"
  providers = {
    # useradmin is enough to create roles, but we cannot drop them after future grants are added for the role...
    # so we must use securityadmin in order to be able to drop the roles when we destroy.
    snowflake = snowflake.securityadmin
  }

  roles = var.roles
}

# -----------------------------------------------------------------------------
# Users
# (must be a module so we can force use of `useradmin` role by provider)
module users {
  source = "./users"
  providers = {
    snowflake = snowflake.useradmin
  }

  users = var.users
  depends_on_roles = module.roles
  depends_on_warehouses = snowflake_warehouse.warehouses
}

# -----------------------------------------------------------------------------
# Grants on objects to roles
# (must be a module so we can force use of `securityadmin` role by provider)
module grants_objects {
  source = "./grants/objects"
  providers = {
    snowflake = snowflake.securityadmin
  }

  count                 = length(var.grants_objects)
  privileges            = var.grants_objects[count.index].privileges
  on_object_type        = var.grants_objects[count.index].on_object_type
  on_object_names       = var.grants_objects[count.index].on_object_names
  in_parent_object_type = var.grants_objects[count.index].in_parent_object_type
  in_parent_object_name = var.grants_objects[count.index].in_parent_object_name
  on_future             = var.grants_objects[count.index].on_future
  to_role_names         = var.grants_objects[count.index].to_role_names

  # We require all objects to be created before grants are made on them
  depends_on = [
    snowflake_database.databases,
    snowflake_schema.schemas,
    module.tables_template,
    module.tables_change_version,
    snowflake_file_format.file_formats,
    snowflake_warehouse.warehouses,
    module.roles
  ]

  # and we pass all the objects to the module so it can reference them when adding grants
  databases             = snowflake_database.databases
  schemas               = snowflake_schema.schemas
  tables                = concat(var.tables_template, var.tables_change_version)
  views                 = [] # snowflake_view.views
  stages                = [] # snowflake_stage.stages
  file_formats          = snowflake_file_format.file_formats
  warehouses            = snowflake_warehouse.warehouses
  roles                 = module.roles
}


# -----------------------------------------------------------------------------
# Grants on objects to roles
# (must be a module so we can force use of `securityadmin` role by provider)
module grants_roles {
  source = "./grants/roles"
  providers = {
    snowflake = snowflake.securityadmin
  }

  count           = length(var.grants_roles)
  role_names      = var.grants_roles[count.index].role_names
  to_object_type  = var.grants_roles[count.index].to_object_type
  to_object_names = var.grants_roles[count.index].to_object_names

  # We require roles and users to be created before grants are made for them
  depends_on = [
    module.roles,
    module.users
  ]
}
