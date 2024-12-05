variable "public_cidrs" {}
variable "private_cidrs" {}
variable "public_sn_count" {}
variable "max_subnet" {}

variable "name" {
  type = string
}

variable "customer" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_rtb_id" {
  type = string
}

variable "public_rtb_id" {
  type = string
}
