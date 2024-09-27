# VPC Variables
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "WEZVATECH"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_tags" {
  description = "Tags for the VPC"
  type        = string
  default     = "Demo VPC"
}

# Subnet
variable "public_subnets" {
  description = "A list of public subnets cidr inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of public subnets cidr inside the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnet_tags" {
  type        = string
  default     = "public"
}

variable "private_subnet_tags" {
  type        = string
  default     = "private"
} 

variable "igw_tags" {
  type        = string
  default     = "IGW"
}

variable "sg_public_ingress" {
  description = "List of ingress rules to set on the security group"
  type        = list(map(string))
  default     = []
}

variable "sg_public_egress" {
  description = "List of egress rules to set on the security group"
  type        = list(string)
  default     = []
}

variable "sg_private_ingress" {
  description = "List of ingress rules to set on the security group"
  type        = list(string)
  default     = []
}

variable "sg_private_egress" {
  description = "List of egress rules to set on the security group"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "nat_gateway_destination_cidr_block" {
  description = "Used to pass a custom destination route for private NAT Gateway. If not specified, the default 0.0.0.0/0 is used as a destination route"
  type        = string
  default     = "0.0.0.0/0"
}

variable "reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  type        = bool
  default     = false
}

variable "external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = list(string)
  default     = []
}

