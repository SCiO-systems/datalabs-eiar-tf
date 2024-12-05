variable "vpc_id" {}
variable "public_subnets" {}
variable "private_subnets" {}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "customer" {
  type    = string
}

variable "node_groups" {
  description = "List of maps, where each map describes a node group"
  type = list(object({
    instance_types = list(string)
    disk_size      = number
    desired_size   = number
    max_size       = number
    min_size       = number
  }))
  default = []
}