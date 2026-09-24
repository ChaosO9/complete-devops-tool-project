module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

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
      capacity_type  = "SPOT"
    }
  }

  cluster_security_group_additional_rules = {
    ingress_jenkins = {
      description = "Allow Jenkins Agent to access EKS Control Plane"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [data.aws_vpc.devops_vpc.cidr_block]
    }
  }

  tags = {
    "eks:cluster-name" = var.cluster_name
    Terraform          = "true"
    Environment        = "devops"
  }

  access_entries = {
    jenkins_agent = {
      principal_arn = "arn:aws:iam::486517829385:role/devops-ssm-role"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

}
