variable "region" {
  description = "AWS Region where to provision VPC Network"
  default     = "us-east-1"
}

variable "aws_account_id" {
  type        = string
  default     = "975050295384"
  description = "AWS Account Number"
}

variable "tags" {
  description = "Tags for resources"
  # var.tags["pelias"]
  default = {
    gitlab = {
      service = "gitlab"
    }
    pelias = {
      service = "pelias"
    }
  }
}

#### EKS #####

variable "vpc_id" {
  default = "vpc-00ae6ef3f15d59c25"
  description = "VPC to deploy the cluster"
}

variable "subnet_ids" {
  # default = ["subnet-09efd80c2d17f0561", "subnet-077762943ffa15fc8", "subnet-0e33454352968f6cc"]
  default = ["subnet-09efd80c2d17f0561", "subnet-0e33454352968f6cc"]
  description = "Private subnets for the cluster"
}

variable "eks_instance_types"  {
  default = ["t2.medium"]
}

/*
Pod limits per instance type
https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt
Amazon VPC CNI plugin increases pods per node limits
https://aws.amazon.com/blogs/containers/amazon-vpc-cni-increases-pods-per-node-limits/
*/