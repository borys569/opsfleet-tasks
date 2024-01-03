# data "aws_eks_cluster" "eks_dev" {
#   name = local.cluster_name
#   #depends_on = [module.eks_dev.cluster_id]
# }

# data "aws_eks_cluster_auth" "eks_dev" {
#   name = local.cluster_name
#   #depends_on = [module.eks_dev.cluster_id]
# }