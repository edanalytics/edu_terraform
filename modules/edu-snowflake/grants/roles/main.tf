terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.36.0"
    }
  }
  required_version = ">= 1.2.0"
}

# See https://docs.snowflake.com/en/sql-reference/sql/grant-role.html

# OBJECT GRANT SPECIFICATION:
#
# { # ROLE GRANT
# 	role_names      = [ "role1", "role2", ... ]
#   to_object_type  = "ROLE | USER"
#   to_object_names = [ "role1", "role2", ... ]
# }

# -----------------------------------------------------------------------------
# Role-to-role grants
resource snowflake_role_grants grants_role_role {
  for_each       = {
    for q in setproduct(var.role_names, var.to_object_type=="ROLE" ? var.to_object_names : []) : "GRANT ${q[0]} TO ROLE ${q[1]}" => {
      role       = q[0]
      to_object  = q[1]
    }
  }
  role_name      = each.value.role
  roles          = [ each.value.to_object ]
}

# -----------------------------------------------------------------------------
# Role-to-user grants
resource snowflake_role_grants grants_role_user {
  for_each       = {
      for q in setproduct(var.role_names, var.to_object_type=="USER" ? var.to_object_names : []) : "GRANT ${q[0]} TO USER ${q[1]}" => {
      role       = q[0]
      to_object  = q[1]
    }
  }
  role_name      = each.value.role
  users          = [ each.value.to_object ]
}
