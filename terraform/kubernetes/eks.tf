module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  vpc_id     = data.aws_vpc.devops_vpc.id
  subnet_ids = data.aws_subnets.devops_private_subnets.ids

  eks_managed_node_groups = {
    default = {
      name           = "default-ng"
      instance_types = ["t4g.small"]
      ami_type       = "AL2023_ARM_64_STANDARD"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    "eks:cluster-name" = var.cluster_name
    Terraform          = "true"
    Environment        = "devops"
  }
}
