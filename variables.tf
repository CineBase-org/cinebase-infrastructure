variable "project-name" {
  type = string
}

# ================== NETWORK ===================

variable "vpc_cidr_block" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    public            = bool
  }))
}