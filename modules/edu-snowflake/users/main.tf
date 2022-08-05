terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.36.0"
    }
  }
  required_version = ">= 1.2.0"
}

resource snowflake_user users {
  count             = length(var.users)
  name              = var.users[count.index].name
  comment           = var.users[count.index].comment
  default_warehouse = var.users[count.index].default_warehouse
  default_namespace = var.users[count.index].default_namespace
  default_role      = var.users[count.index].default_role
  depends_on        = [ var.depends_on_roles, var.depends_on_warehouses ]
}