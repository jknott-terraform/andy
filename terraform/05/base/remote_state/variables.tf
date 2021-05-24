variable "region" {
  description = "The AWS region"
  default = "us-east-1"
}

variable "prefix" {
  description = "The name of our org"
  default     = "tfbandy"
}

variable "environment" {
  description = "The environment name"
  default     = "base"
}