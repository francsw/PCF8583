variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "GameVM"
}

variable "region" {
  description = "Value of the Region for the EC2 instance"
  type        = string
  default     = "eu-west-2"
}

variable "subnet_region" {
  description = "Value of the Region for the subnet "
  type        = string
  default     = "eu-west-2b"
}

variable "allow_from_ip" {
  description = "Value of the IPs to allow access from"
  type        = string
  default     = "93.119.27.219/32"
}
