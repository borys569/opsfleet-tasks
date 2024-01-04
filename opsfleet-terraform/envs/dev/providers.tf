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

provider "kubernetes" {
  #alias                  = "v3-eks-dev"
  host                   = module.eks_dev.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_dev.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks_dev.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  #alias                   = "v3-eks-dev"
  kubernetes {
    host                   = module.eks_dev.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_dev.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks_dev.cluster_name]
      command     = "aws"
  }
  }
}

