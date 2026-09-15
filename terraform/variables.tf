variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.small"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-0f1329677c7e5aba8"
}