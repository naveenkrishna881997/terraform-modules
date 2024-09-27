variable "create_elb" {
  description = "Create the elb or not"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the ELB"
  type        = string
  default     = "wezvatech"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default = null
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

variable "subnets" {
  description = "A list of subnet IDs to attach to the ELB"
  type        = list(string)
}

variable "internal" {
  description = "If true, ELB will be an internal ELB"
  type        = bool
}

variable "cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "connection_draining" {
  description = "Boolean to enable connection draining"
  type        = bool
  default     = false
}

variable "connection_draining_timeout" {
  description = "The time in seconds to allow for connections to drain"
  type        = number
  default     = 300
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "listener" {
  description = "A list of listener blocks"
  type        = list(map(string))
}

variable "access_logs" {
  description = "An access logs block"
  type        = map(string)
  default     = {}
}

variable "health_check" {
  description = "A health check block"
  type        = map(string)
}
