variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "name" {
  type    = string
  default = "anaoum"
}

variable "customer" {
  type    = string
  default = "fys"
}

variable "public_cidrs" {
  type    = list(string)
  default = ["10.0.100.0/24", "10.0.101.0/24"]
}

variable "private_cidrs" {
  type    = list(string)
  default = ["10.0.102.0/24", "10.0.103.0/24"]
}

variable "vpc_id" {
  type    = string
  default = "vpc-xxx"
}

variable "private_rtb_id" {
  type    = string
  default = "rtb-yyy"
}

variable "public_rtb_id" {
  type    = string
  default = "rtb-zzz"
}

variable "node_groups" {
  type = list(object({
    instance_types = list(string)
    disk_size      = number
    desired_size   = number
    max_size       = number
    min_size       = number
  }))

  default = [{
    instance_types = ["t3.medium"]
    disk_size      = 20
    desired_size   = 2
    max_size       = 5
    min_size       = 1
    },
    {
      instance_types = ["t3.large"]
      disk_size      = 30
      desired_size   = 1
      max_size       = 3
      min_size       = 1
  }]
}
