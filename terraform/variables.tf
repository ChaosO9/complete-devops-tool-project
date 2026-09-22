variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.small"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-0b72c6129a4fc2667"
}

variable "jenkins_agent_count" {
  description = "Max Jenkins Instance"
  type        = number
  default     = 1
}
