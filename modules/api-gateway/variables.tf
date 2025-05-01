variable "api-name" {
  type        = string
  description = "Name of the API Gateway"
  default     = "defualt api gateway"
}

variable "lb-dns" {
  type        = string
  description = "dns of the LB"
  default     = ""
}
variable "connection_type" {
  type    = string
  default = "VPC_LINK"
}

variable "connection_id" {
  type    = string
  default = ""
}

