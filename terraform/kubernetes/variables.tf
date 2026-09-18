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

variable "vpc_id" {
  description = "VPC ID where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of at least 2 subnet IDs in different AZs"
  type        = list(string)
}

variable "artifactory_server" {
  description = "Docker registry domain"
  type        = string
}

variable "artifactory_username" {
  description = "Artifactory username"
  type        = string
}
