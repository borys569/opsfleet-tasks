# the role for devs

resource "kubernetes_cluster_role" "backend-developers" {
  metadata {
    name = "backend-developers"
  }

  # view all resources
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "backend-developers" {
  metadata {
    name = "view"
    # namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "backend-developers"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "backend-developers"
    namespace = ""
  }

}

## SA for the app ##

resource "kubernetes_service_account" "my-service-account" {
  metadata {
    name      = "my-service-account"
    namespace = "default"
    # Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::975050295384:role/S3ReadWriteDecryptRole
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.aws_account_id}:role/S3ReadWriteDecryptRole"
    }
  }
}

############ Example SA ############

# resource "kubernetes_service_account" "helm-user" {
#   metadata {
#     name      = "helm-user"
#     namespace = "default"
#   }
# }

# resource "kubernetes_cluster_role_binding" "helm-user" {
#   metadata {
#     name = "helm-user"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = "helm-user"
#     namespace = "default"
#   }
# }