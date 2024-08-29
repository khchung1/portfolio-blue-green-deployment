variable "vpc_id" {
  description = "existing VPC"
  type        = string
  default     = "vpc-0411632e16afd09a2"
}

variable "blue_weight" {
  description = "assign weightage for blue environment"
  type = number
  default = 70
}

variable "green_weight" {
  description = "assign weightage for blue environment"
  type = number
  default = 30
}