terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.36.0"
    }
  }
  required_version = ">= 1.2.0"
}

resource snowflake_role roles {
  count   = length(var.roles)
  name    = var.roles[count.index].name
  comment = var.roles[count.index].comment
}