# terraform {
#   # backend "s3" {
#   #   bucket         = "loop-v3-terraform-states"
#   #   key            = "dev/terraform.tfstate"
#   #   region         = "us-east-1"
#   #   dynamodb_table = "terraform-v3-dev"
#   # }

#   required_providers {
#     kubernetes = {
#       source = "hashicorp/kubernetes"
#     }

#     # helm = {
#     #   source = "hashicorp/helm"
#     # }

#     # kubectl = {
#     #   source  = "gavinbunney/kubectl"
#     #   version = ">= 1.7.0"
#     # }

#   }

# }

provider "aws" {
  region = var.region

  # Make it faster by skipping some checks
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true

}

### providers for 'eks-opsfleet' cluster ###
/*
when adding clsters add providers with new alias and pass to the module
*/

# provider "kubernetes" {
#   alias                  = "eks-opsfleet"
#   host                   = data.aws_eks_cluster.eks_dev.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_dev.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.eks_dev.token
# }

# provider "helm" {
#   alias                    = "eks-opsfleet"
#   kubernetes {
#     host                   = data.aws_eks_cluster.eks_dev.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_dev.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.eks_dev.token
#   }
# }

# provider "kubectl" {
#   alias                  = "eks-opsfleet"
#   host                   = data.aws_eks_cluster.eks_dev.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_dev.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.eks_dev.token
#   load_config_file       = false # do not use local configfile
# }

