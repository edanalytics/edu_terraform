# If you have custom tables you want to create/manage with Terraform, add them here.
# (We have to do this because the way you define table columns cannot go in a
# .tfvars file - the syntax is invalid.)

# Example... for full syntax/documentation see
# https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/table

# Add (and uncomment) a block like this for each table you want to manage with Terraform:

# resource snowflake_table some_table {
#   database   = "some_database"
#   schema     = "some_schema"
#   name       = "some_table"
#   depends_on = [ snowflake_database.databases, snowflake_schema.schemas ]
# 
#   column {
#       name = "column1"
#       type = "string"
#   }
#   column {
#       name = "column2"
#       type = "int"
#   }
#   column {
#       name = "column3"
#       type = "date"
#   }
#   column {
#       name = "column4"
#       type = "timestamp"
#   }
#   column {
#       name = "column5"
#       type = "variant"
#   }
# }