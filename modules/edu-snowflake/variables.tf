# variable databases {}
# variable schemas {}
# variable tables_template {}
# variable tables_change_version {}
# variable file_formats {}
# variable warehouses {}
# variable roles {}
# variable users {}
# variable grants_objects {}
# variable grants_roles {}
variable snowflake_profile {
    type = string
}
variable environments {
    type = list(object({
        name    = string
        prefix  = string
        suffix = string
    }))
    default = [
        {
            name = "prod"
            prefix = ""
            suffix = ""
        },
        {
            name = "dev"
            prefix = "dev_"
            suffix = "_dev"
        }
    ]
}