terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.36.0"
    }
  }
  required_version = ">= 1.2.0"
}

# See https://docs.snowflake.com/en/sql-reference/sql/grant-privilege.html

# OBJECT GRANT SPECIFICATION:
#
# { # OBJECT GRANT
# 	privileges             = [ "ALL", "ALL PRIVILEGES", "SELECT", "..." ]
#   on_object_type         = "DATABASE | SCHEMA | TABLE | VIEW | STAGE | FILE_FORMAT | WAREHOUSE"
#   on_object_names        = [ "ALL", "*", "whatever1", "whatever2", ... ]
#   on_future              = true | false
#   in_parent_object_type  = "NONE | DATABASE | SCHEMA"
#   in_parent_object_name  = "database1.schema1"
#   to_role_names          = [ "role1", "role12", ... ]
#   # [depends on snowflake databases, schemas, tables, views, stages, file_formats, warehouses, and roles]
# }

locals {
  # Translate ALL privileges to an actual list, since Terraform-Snowflake doesn't support ALL
  # This is super gross, but it works :(
  privileges = (
    contains([for privilege in var.privileges : upper(privilege)], "ALL")
    || contains([for privilege in var.privileges : upper(privilege)], "ALL PRIVILEGES")
  ) ? (
    var.on_object_type=="DATABASE" ? ["MODIFY", "MONITOR", "USAGE", "CREATE SCHEMA", "IMPORTED PRIVILEGES"] : (
      var.on_object_type=="SCHEMA" ? ["CREATE PIPE", "CREATE STREAM", "CREATE TASK", "CREATE MASKING POLICY", "MODIFY", "MONITOR", "CREATE TABLE", "CREATE STAGE", "CREATE EXTERNAL TABLE", "ADD SEARCH OPTIMIZATION", "CREATE FILE FORMAT", "CREATE TEMPORARY TABLE", "USAGE", "CREATE VIEW", "CREATE SEQUENCE", "CREATE FUNCTION", "CREATE PROCEDURE", "CREATE MATERIALIZED VIEW"] : (
        var.on_object_type=="TABLE" ? ["SELECT", "INSERT", "UPDATE", "TRUNCATE", "DELETE", "REFERENCES"] : (
          var.on_object_type=="VIEW" ? ["SELECT", "REFERENCES"] : (
            var.on_object_type=="STAGE" ? ["USAGE", "READ", "WRITE"] : (
              var.on_object_type=="FILE FORMAT" ? ["USAGE"] : (
                var.on_object_type=="WAREHOUSE" ? ["MODIFY", "MONITOR", "OPERATE", "USAGE"] : []
              )
            )
          )
        )
      )
    )
  ) : [for privilege in var.privileges : upper(privilege)]

  selected_databases = (
      contains([for database in var.on_object_names : upper(database)], "ALL")
      || contains([for database in var.on_object_names : upper(database)], "ALL DATABASES")
    ) ? (
      toset([ for database in var.databases : database.name if var.on_object_type=="DATABASE" ])
    ) : (upper(var.on_object_type)=="DATABASE" ? var.on_object_names : [])
    
  
  selected_schemas = (
      contains([for schema in var.on_object_names : upper(schema)], "ALL")
      || contains([for schema in var.on_object_names : upper(schema)], "ALL SCHEMAS") 
    ) ? ( toset([ for schema in var.schemas  : schema.name if var.on_object_type=="SCHEMA" ])
    ) : ( upper(var.on_object_type)=="SCHEMA" ? var.on_object_names : [] )

  selected_tables = (
      contains([for table in var.on_object_names : upper(table)], "ALL")
      || contains([for table in var.on_object_names : upper(table)], "ALL TABLES")
    ) ? ( toset([ for table in var.tables : table.name if var.on_object_type=="TABLE" ])
    ) : ( upper(var.on_object_type)=="TABLE" ? var.on_object_names : [] )

  selected_views = (
      contains([for view in var.on_object_names : upper(view)], "ALL")
      || contains([for view in var.on_object_names : upper(view)], "ALL VIEWS")
    ) ? ( toset([ for view in var.views : view if var.on_object_type=="VIEW" ])
    ) : ( upper(var.on_object_type)=="VIEW" ? var.on_object_names : [] )

  selected_stages = (
      contains([for stage in var.on_object_names : upper(stage)], "ALL")
      || contains([for stage in var.on_object_names : upper(stage)], "ALL STAGES")
    ) ? ( toset([ for stage in var.stages : stage if var.on_object_type=="STAGE" ])
    ) : ( upper(var.on_object_type)=="STAGE" ? var.on_object_names : [] )

  selected_file_formats = (
      contains([for file_format in var.on_object_names : upper(file_format)], "ALL")
      || contains([for file_format in var.on_object_names : upper(file_format)], "ALL FILE FORMATS") 
    ) ? ( toset([ for file_format in var.file_formats : file_format.name if var.on_object_type=="FILE FORMAT" ])
    ) : ( upper(var.on_object_type)=="FILE FORMAT" ? var.on_object_names : [] )

  selected_warehouses = (
      contains([for warehouse in var.on_object_names : upper(warehouse)], "ALL")
      || contains([for warehouse in var.on_object_names : upper(warehouse)], "ALL WAREHOUSES")
    ) ? ( toset([ for warehouse in var.warehouses : warehouse.name if var.on_object_type=="WAREHOUSE" ])
    ) : ( upper(var.on_object_type)=="WAREHOUSE" ? var.on_object_names : [] )
  
  # This calculates the database part of a grant on something `IN database.schema` or `IN database`
  parent_database_name = (
      upper(var.in_parent_object_type)=="DATABASE"
    ) ? ( var.in_parent_object_name
    ) : (
      ( upper(var.in_parent_object_type)=="SCHEMA" && replace(var.in_parent_object_name,".","")!=var.in_parent_object_name
      ) ? ( split(".", var.in_parent_object_name)[0] ) : "")

  # This calculates the schema part of a grant on something `IN database.schema` or `IN database`
  parent_schema_name = (
      upper(var.in_parent_object_type)=="SCHEMA"
    ) ? ( var.in_parent_object_name
    ) : (
      ( upper(var.in_parent_object_type)=="DATABASE" && replace(var.in_parent_object_name,".","")!=var.in_parent_object_name
      ) ? ( split(".", var.in_parent_object_name)[1] ) : "")
}

resource snowflake_database_grant edu_snowflake_grants_database {
  for_each      = {
    for q in setproduct(local.privileges, local.selected_databases) : "GRANT ${q[0]} ON DATABASE ${q[1]}}" => {
      privilege = q[0]
      database  = q[1]
    }
  }
  privilege     = each.value.privilege
  database_name = each.value.database
  roles         = var.to_role_names
}


resource snowflake_schema_grant edu_snowflake_grants_schema {
  for_each      = {
    for q in setproduct(local.privileges, var.on_future ? [] : local.selected_schemas) : "GRANT ${q[0]} ON SCHEMA ${q[1]}" => {
      privilege = q[0]
      schema    = q[1]
    }
  }
  privilege     = each.value.privilege
  database_name = local.parent_database_name
  schema_name   = each.value.schema
  roles         = var.to_role_names
}
resource snowflake_schema_grant edu_snowflake_grants_schema_future {
  for_each      = {
    for q in setproduct(local.privileges, var.on_future && upper(var.on_object_type)=="SCHEMA" ? ["FUTURE"] : []) : "GRANT ${q[0]} ON SCHEMA ${q[1]}" => {
      privilege = q[0]
      schema    = q[1]
    }
  }
  privilege     = each.value.privilege
  database_name = local.parent_database_name
  on_future     = true
  roles         = var.to_role_names
}

resource snowflake_table_grant edu_snowflake_grants_table {
  for_each      = {
    for q in setproduct(local.privileges, var.on_future ? [] : local.selected_tables) : "GRANT ${q[0]} ON TABLE ${q[1]} IN ${local.parent_database_name}.${local.parent_schema_name}" => {
      privilege = q[0]
      table     = q[1]
    }
  }
  privilege     = each.value.privilege
  database_name = local.parent_database_name
  schema_name   = local.parent_schema_name
  table_name    = each.value.table
  roles         = var.to_role_names
}
resource snowflake_table_grant edu_snowflake_grants_table_future {
  for_each      = {
    for q in setproduct(local.privileges, var.on_future && upper(var.on_object_type)=="TABLE" ? ["FUTURE"] : [] ) : "GRANT ${q[0]} ON TABLE ${q[1]} IN ${local.parent_database_name}.${local.parent_schema_name}" => {
      privilege = q[0]
      table     = q[1]
    }
  }
  privilege     = each.value.privilege
  database_name = local.parent_database_name
  schema_name   = local.parent_schema_name
  roles         = var.to_role_names
  on_future     = true
}

resource snowflake_view_grant edu_snowflake_grants_view {
  for_each      = {
    for q in setproduct(local.privileges, var.on_future ? [] : local.selected_views) : "GRANT ${q[0]} ON VIEW ${q[1]} IN ${local.parent_database_name}.${local.parent_schema_name}" => {
      privilege = q[0]
      view      = q[1]
    }
  }
  privilege     = each.value.privilege
  database_name = local.parent_database_name
  schema_name   = local.parent_schema_name
  view_name     = each.value.view
  roles         = var.to_role_names
}
resource snowflake_view_grant edu_snowflake_grants_view_future {
  for_each      = {
    for q in setproduct(local.privileges, var.on_future && upper(var.on_object_type)=="VIEW" ? ["FUTURE"] : []) : "GRANT ${q[0]} ON VIEW ${q[1]} IN ${local.parent_database_name}.${local.parent_schema_name}" => {
      privilege = q[0]
      view      = q[1]
    }
  }
  privilege     = each.value.privilege
  database_name = local.parent_database_name
  schema_name   = local.parent_schema_name
  roles         = var.to_role_names
  on_future     = true
}

resource snowflake_stage_grant edu_snowflake_grants_stage {
  for_each      = {
    for q in setproduct(local.privileges, var.on_future ? [] : local.selected_stages) : "GRANT ${q[0]} ON STAGE ${q[1]} IN ${local.parent_database_name}.${local.parent_schema_name}" => {
      privilege = q[0]
      stage     = q[1]
    }
  }
  privilege     = each.value.privilege
  database_name = local.parent_database_name
  schema_name   = local.parent_schema_name
  stage_name    = each.value.stage
  roles         = var.to_role_names
}
resource snowflake_stage_grant edu_snowflake_grants_stage_future {
  for_each      = {
    for q in setproduct(local.privileges, var.on_future && upper(var.on_object_type)=="STAGE" ? ["FUTURE"] : []) : "GRANT ${q[0]} ON STAGE ${q[1]} IN ${local.parent_database_name}.${local.parent_schema_name}" => {
      privilege = q[0]
      stage     = q[1]
    }
  }
  privilege     = each.value.privilege
  database_name = local.parent_database_name
  schema_name   = local.parent_schema_name
  roles         = var.to_role_names
  on_future     = true
}

resource snowflake_file_format_grant edu_snowflake_grants_file_format {
  for_each         = {
    for q in setproduct(local.privileges, var.on_future ? [] : local.selected_file_formats) : "GRANT ${q[0]} ON FILE FORMAT ${q[1]} IN ${local.parent_database_name}.${local.parent_schema_name}" => {
      privilege    = q[0]
      file_format  = q[1]
    }
  }
  privilege        = each.value.privilege
  database_name    = local.parent_database_name
  schema_name      = local.parent_schema_name
  file_format_name = each.value.file_format
  roles            = var.to_role_names
}
resource snowflake_file_format_grant edu_snowflake_grants_file_format_future {
  for_each         = {
    for q in setproduct(local.privileges, var.on_future && upper(var.on_object_type)=="FILE FORMAT" ? ["FUTURE"] : []) : "GRANT ${q[0]} ON FILE FORMAT ${q[1]} IN ${local.parent_database_name}.${local.parent_schema_name}" => {
      privilege    = q[0]
      file_format  = q[1]
    }
  }
  privilege        = each.value.privilege
  database_name    = local.parent_database_name
  schema_name      = local.parent_schema_name
  roles            = var.to_role_names
  on_future        = true
}

resource snowflake_warehouse_grant "edu_snowflake_grants_warehouse" {
  for_each      = {
    for q in setproduct(local.privileges, local.selected_warehouses) : "GRANT ${q[0]} ON WAREHOUSE ${q[1]}" => {
      privilege = q[0]
      warehouse  = q[1]
    }
  }
  privilege      = each.value.privilege
  warehouse_name = each.value.warehouse
  roles          = var.to_role_names
}
