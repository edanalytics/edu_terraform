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
            suffix = "_prod"
        },
        {
            name = "dev"
            prefix = "dev_"
            suffix = "_dev"
        }
    ]
}