variable in_parent_object_type {
  description = "Object type to grant privileges in (parent of `on_object_type`)"
  type        = string
  default     = ""

  validation {
    condition     = contains(["", "DATABASE", "SCHEMA"], upper(var.in_parent_object_type))
    error_message = "`in_parent_object_type` must be empty string or DATABASE or SCHEMA."
  }
}

variable in_parent_object_name {
  description = "Object name to grant privileges in (parent of `on_object_type`)"
  type        = string
  default     = ""

  # validation {
  #   condition     = anytrue([
  #     var.in_parent_object_type=="" && var.in_parent_object_name=="",
  #     var.in_parent_object_type!="" && var.in_parent_object_name!=""
  #   ])
  #   error_message = "`in_parent_object_names` must be empty or a list of DATABASE or SCHEMA names."
  # }
}

variable on_object_type {
  description = "Object type to grant privileges on"
  type        = string
  default     = ""

  validation {
    condition     = contains(["DATABASE", "SCHEMA", "TABLE", "VIEW", "STAGE", "FILE FORMAT", "WAREHOUSE"], upper(var.on_object_type))
    error_message = "`on_object_type` must be one of DATABASE, SCHEMA, TABLE, VIEW, STAGE, or FILE FORMAT."
  }
}

variable on_object_names {
  description = "Object names to grant privileges on"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.on_object_names)>0
    error_message = "`on_object_names` must be a list of object names or `ALL [on_object_type]S`."
  }
}

variable privileges {
  description = "List of privileges to grant"
  type        = list(string)
  default     = []

  # validation {
  #   condition     = anytrue([
  #     var.on_object_type=="DATABASE" && alltrue([
  #       for privilege in var.privileges : contains(["ALL", "ALL PRIVILEGES", "MODIFY", "MONITOR", "USAGE", "CREATE SCHEMA", "IMPORTED PRIVILEGES"], upper(privilege))
  #     ]),
  #     var.on_object_type=="SCHEMA" && alltrue([
  #       for privilege in var.privileges : contains(["ALL", "ALL PRIVILEGES", "CREATE PIPE", "CREATE STREAM", "CREATE TASK", "CREATE MASKING POLICY", "MODIFY", "MONITOR", "CREATE TABLE", "CREATE STAGE", "CREATE EXTERNAL TABLE", "ADD SEARCH OPTIMIZATION", "CREATE FILE FORMAT", "CREATE TEMPORARY TABLE", "USAGE", "CREATE VIEW", "CREATE SEQUENCE", "CREATE FUNCTION", "CREATE PROCEDURE", "CREATE MATERIALIZED VIEW"], upper(privilege))
  #     ]),
  #     var.on_object_type=="TABLE" && alltrue([
  #       for privilege in var.privileges : contains(["ALL", "ALL PRIVILEGES", "SELECT", "INSERT", "UPDATE", "TRUNCATE", "DELETE", "REFERENCES"], upper(privilege))
  #     ]),
  #     var.on_object_type=="VIEW" && alltrue([
  #       for privilege in var.privileges : contains(["ALL", "ALL PRIVILEGES", "SELECT", "REFERENCES"], upper(privilege))
  #     ]),
  #     var.on_object_type=="STAGE" && alltrue([
  #       for privilege in var.privileges : contains(["ALL", "ALL PRIVILEGES", "USAGE", "READ", "WRITE"], upper(privilege))
  #     ]),
  #     var.on_object_type=="FILE FORMAT" && alltrue([
  #       for privilege in var.privileges : contains(["ALL", "ALL PRIVILEGES", "USAGE"], upper(privilege))
  #     ]),
  #     var.on_object_type=="WAREHOUSE" && alltrue([
  #       for privilege in var.privileges : contains(["ALL", "ALL PRIVILEGES", "MODIFY", "MONITOR", "OPERATE", "USAGE"], upper(privilege))
  #     ])
  #   ])
  #   error_message = "`privileges` contains an invalid value for the given `on_object_type`."
  # }
}

variable on_future {
  description = "Whether to grant privileges to objects created in the future"
  type        = bool
  default     = false
}

variable to_role_names {
  description = "Roles to grant privileges to"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.to_role_names)>0
    error_message = "`to_role_names` must be a list of role names."
  }
}

variable databases {}
variable schemas {}
variable tables {}
variable views {}
variable stages {}
variable file_formats {}
variable warehouses {}
variable roles {}