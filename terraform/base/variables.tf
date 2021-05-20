variable "region" {
  type        = string
  description = "The aws region"
  default     = "us-east-1"
}

variable "region_list" {
  type        = list(string)
  description = "AWS availability zones"
  default     = ["us-east-1a", "us-west-1b"]
}

variable "ami" {
  type = map(string)
  default = {
    us-east-1 = "ami-0d729a60"
    us-west-1 = "ami-7c4b331c"
  }
  description = "The AMIs to use"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs"
  default     = ["sg-4f713c35"]
}