variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "DevOps-Project"
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  type        = string
  default     = "1.30"
}

variable "artifactory_server" {
  description = "Docker registry domain"
  type        = string
  default     = "irfannoorh.jfrog.io"
}

variable "artifactory_username" {
  description = "Artifactory username"
  type        = string
  default     = "maud0@eldver.com"
}
