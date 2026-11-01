variable "resource_groups" {
  description = "Dictionary of Resource Groups"
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
}

