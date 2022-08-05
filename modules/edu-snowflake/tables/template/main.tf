terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.36.0"
    }
  }
  required_version = ">= 1.2.0"
}

resource snowflake_table tables {
  count      = length(var.tables)
  name       = var.tables[count.index].name
  database   = var.tables[count.index].database
  schema     = var.tables[count.index].schema
  depends_on = [ var.depends_on_databases, var.depends_on_schemas ]

  column {
      name = "filename"
      type = "string"
  }
  column {
      name = "file_row_number"
      type = "int"
  }
  column {
      name = "tenant_code"
      type = "string"
  }
  column {
      name = "api_year"
      type = "int"
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
      name = "name"
      type = "string"
  }
  column {
      name = "v"
      type = "variant"
  }
}