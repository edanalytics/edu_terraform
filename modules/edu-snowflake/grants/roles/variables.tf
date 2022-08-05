variable role_names {
  description = "List of roles to grant"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.role_names)>0
    error_message = "`role_names` must be a list of roles."
  }
}

variable to_object_type {
  description = "Object type to grant the role to"
  type        = string
  default     = ""

  validation {
    condition     = contains(["ROLE", "USER"], upper(var.to_object_type))
    error_message = "`to_object_type` must be either ROLE or USER."
  }
}

variable to_object_names {
  description = "Roles or users to grant the role to"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.to_object_names)>0
    error_message = "`to_object_names` must be a list of role or user names."
  }
}
