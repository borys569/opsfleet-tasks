locals {
  cluster_name   = "eks-opsfleet"
  #main_admin_arn = "arn:aws:iam::${var.aws_account_id}:role/OrganizationAccountAccessRole"
  main_admin_arn = "arn:aws:iam::975050295384:user/boryss"
  node_disk_size = 10
}

#####################

module "eks_dev" {

  # pass a provider alias to point this module to a particular EKS cluster
  # and and fix issues with aws configmap
  # providers = {
  #   kubernetes = kubernetes.eks-opsfleet
  # }

  source                          = "terraform-aws-modules/eks/aws"
  version                         = "19.10.0"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.28" # keeping the version here so it is esier to perform upgrades
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  # create_aws_auth_configmap       = true
  manage_aws_auth_configmap = false # managed in the module eks-addons
  enable_irsa               = true
  create_kms_key            = true

  kms_key_administrators = [
    "arn:aws:iam::${var.aws_account_id}:root",
    local.main_admin_arn
  ]

  cluster_addons = {
    coredns = {
      #addon_version = "v1.10.1-eksbuild.1"
      most_recent = true
    }
    kube-proxy = {
      #addon_version = "v1.27.1-eksbuild.1"
      most_recent = true
    }
    vpc-cni = {
      #addon_version = "v1.12.6-eksbuild.2"
      most_recent = true
    }
    aws-ebs-csi-driver = {
      #addon_version = "v1.26.0-eksbuild.1"
      most_recent = true
    }
  }


  eks_managed_node_groups = {
    "dev_node_gr_01" = {
      desired_size = 1
      min_size     = 1
      max_size     = 1

      instance_types = var.eks_instance_types
      capacity_type = "ON_DEMAND"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = local.node_disk_size
            volume_type = "gp2"
            encrypted   = true
            #kms_key_id            = data.aws_kms_key.ebs_key.arn
            delete_on_termination = true
          }
        }
      }

    # allows fluentbit to write to cliudwatch
    iam_role_additional_policies = {
      CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    }

      labels = {
        role = "wg-1-${local.cluster_name}"
      }

    }
  }

  # aws_auth_roles = [
  #   {
  #     rolearn  = local.main_admin_arn
  #     username = "OrganizationAccountAccessRole"
  #     groups   = ["system:masters"]
  #   }
  # ]

  aws_auth_users = [

    # admins

    {
      userarn  = "arn:aws:iam::${var.aws_account_id}:user/name.name1"
      username = "name.name1"
      groups   = ["system:masters"]
    },

    # developers

    {
      userarn  = "arn:aws:iam::${var.aws_account_id}:user/name.name2"
      username = "name.name2"
      groups   = ["backend-developers"]
    },

  ]

}

## setup addons and permissions

# module "eks_dev_addons" {

#   # pass a provider alias to point this module to a particular EKS cluster
#   providers = {
#     kubernetes = kubernetes.eks-opsfleet
#     helm       = helm.eks-opsfleet
#     kubectl    = kubectl.eks-opsfleet
#   }

#   source = "../../modules/eks-addons"

#   cluster_name      = local.cluster_name # point the module to the EKS cluster
#   oidc_provider_arn = module.eks_dev.oidc_provider_arn

#   namespaces = ["develop", "stage", "test", "dev-renewage", "stable", "ocpp-sim"]

# }
