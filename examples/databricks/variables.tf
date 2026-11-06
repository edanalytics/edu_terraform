# SPDX-FileCopyrightText: 2022 Education Analytics
# SPDX-License-Identifier: MPL-2.0

variable workspace_id {
    type = string
}
variable storage_location {
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
            suffix = "_prod"
        },
        {
            name = "dev"
            prefix = "dev_"
            suffix = "_dev"
        }
    ]
}