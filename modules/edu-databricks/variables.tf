variable databricks_profile {
    type = string
}
variable environments {
    type = list(object({
        name = string
        prefix = string
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
variable workspace_id {
    type = string
}
variable storage_location {
    type = string
}