terraform {
  # backend "s3" {
  #   bucket         = "loop-v3-terraform-states"
  #   key            = "dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-v3-dev"
  # }

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.2"
    }

  }

}

provider "aws" {
  region = var.region

  # Make it faster by skipping some checks
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true

}

# this provider definition is needed for EKS module to be able to controle aws configmap (used for user access management)
provider "kubernetes" {

  host                   = module.eks_dev.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_dev.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks_dev.cluster_name]
    command     = "aws"
  }
}

provider "helm" {

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

