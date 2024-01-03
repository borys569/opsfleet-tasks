# the role for backend devs

resource "kubernetes_cluster_role" "backend-developers" {
  metadata {
    name = "backend-developers"
  }

  # manage custom OCPP resources (listed below)
  rule {
    api_groups = ["*"]
    resources  = ["chargepoints", "settings"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
  }

  # exec
  rule {
    api_groups = ["*"]
    resources  = ["pods/exec"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
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

# resource "kubernetes_config_map" "aws-auth" {

#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     "mapRoles" = <<EOT
# - groups:
#   - system:bootstrappers
#   - system:nodes
#   - system:masters
#   rolearn: arn:aws:iam::121544126352:role/dev_node_gr_1-eks-node-group-20230823101614158900000001
#   username: system:node:{{EC2PrivateDNSName}}
# - groups:
#   - system:masters
#   rolearn: arn:aws:iam::121544126352:role/OrganizationAccountAccessRole
#   username: OrganizationAccountAccessRole
# EOT

#     "mapUsers" = <<EOT
# - groups:
#   - system:masters
#   userarn: arn:aws:iam::121544126352:user/mykhailo.maidan
#   username: mykhailo.maidan
# - groups:
#   - system:masters
#   userarn: arn:aws:iam::121544126352:user/vadym.verovka
#   username: vadym.verovka
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/ihor.kyrylchuk
#   username: ihor.kyrylchuk
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/vasyl.pryshliak
#   username: vasyl.pryshliak
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/andrii.yermakov
#   username: andrii.yermakov
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/daniil.trotsenko
#   username: daniil.trotsenko
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/kostiantyn.tsymbal
#   username: kostiantyn.tsymbal
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/liubomyr.popadiuk
#   username: liubomyr.popadiuk
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/oleh.bozhok
#   username: oleh.bozhok
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/oleksiy.zausalin
#   username: oleksiy.zausalin
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/olesia.storchak
#   username: olesia.storchak
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/pavlo.botnar
#   username: pavlo.botnar
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/serhii.khalymon
#   username: serhii.khalymon
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/taras.baziuk
#   username: taras.baziuk
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/volodymyr.mihdal
#   username: volodymyr.mihdal
# - groups:
#   - backend-developers
#   userarn: arn:aws:iam::121544126352:user/yehor.zubashevskyi
#   username: yehor.zubashevskyi
# EOT
#   }

# }

############ SA for gitlab ############

# this is used by gitlab to deploy OCPP
resource "kubernetes_service_account" "helm-user" {
  metadata {
    name      = "helm-user"
    namespace = "default"
  }
}

resource "kubernetes_cluster_role_binding" "helm-user" {
  metadata {
    name = "helm-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "helm-user"
    namespace = "default"
  }
}

# afterwards you can export the token with k describe secret  helm-user and use it in kubeconfig
resource "kubernetes_secret" "helm-user" {
  metadata {
    name      = "helm-user"
    namespace = "default"
    annotations = {
      "kubernetes.io/service-account.name" = "helm-user"
    }
  }
  type = "kubernetes.io/service-account-token"
}