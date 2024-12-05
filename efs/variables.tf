variable "name" {
  type = string
}

variable "customer" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "cluster_security_group_id" {
  type = list(string)
}
