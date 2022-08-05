terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.36.0"
    }
  }
  required_version = ">= 1.2.0"
}

# Terraform/Snowflake connector doesn't allow "ALL" privileges, you have to specify them explicitly...
# ... so we manually replace "ALL" with the list of privileges for schemas.
# (see https://github.com/Snowflake-Labs/terraform-provider-snowflake/discussions/318)
resource snowflake_table tables {
  count      = length(var.tables)
  name       = var.tables[count.index].name
  database   = var.tables[count.index].database
  schema     = var.tables[count.index].schema
  depends_on = [ var.depends_on_databases, var.depends_on_schemas ]

  column {
      name = "tenant_code"
      type = "string"
  }
  column {
      name = "api_year"
      type = "int"
  }
  column {
      name = "name"
      type = "string"
  }
  column {
      name = "is_deletes"
      type = "boolean"
  }
  column {
      name = "pull_date"
      type = "date"
  }
  column {
      name = "pull_timestamp"
      type = "timestamp" # todo: tz?
  }
  column {
      name = "max_version"
      type = "int"
  }
  column {
      name = "is_active"
      type = "boolean"
  }
}