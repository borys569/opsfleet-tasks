#### Namespaces ####

resource "kubernetes_namespace" "this" {
  for_each = toset(var.namespaces)
  metadata {
    name = each.key
  }
}

#### docker reg credentials ####

resource "kubectl_manifest" "regcred" {
  for_each           = toset(var.namespaces)
  yaml_body          = file("${path.module}/manifests/regcred.yaml")
  override_namespace = each.key
}

## Fluentbit log proccessor ##

/*

Logging configuration
Fluent-bit sends log data to Cloudwathc

https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs-FluentBit.html#Container-Insights-FluentBit-setup
https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch

main yaml source is here:

https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml

the helm chart applies a custom manifest with the configuration for Cloudwathc logging

*/

resource "helm_release" "fluentbit" {
  name       = "fluentbit"
  namespace        = "fluentbit" 
  # repository = "https://fluent.github.io/helm-charts"
  # chart      = "fluent-bit"
  chart            = "${path.module}/manifests/fluentbit"   # config is stored here

  create_namespace = true
  force_update     = false
  recreate_pods    = true # required to read config

  set {
    name  = "cluster_name"
    value = var.cluster_name
  }

  set {
    name  = "aws_region"
    value = "us-east-1"
  }

}


#### metrics server ####

/*
must have for resource usage monitoring
https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html
*/

resource "kubectl_manifest" "mertics_server" {
  yaml_body = file("${path.module}/manifests/metrics-server.yaml")
}

#### kubecost ####

/*

https://docs.aws.amazon.com/eks/latest/userguide/cost-monitoring.html

https://docs.kubecost.com/install-and-configure/install/getting-started

helm upgrade --install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace --values kubecost.values.yaml

terraform import helm_release.example default/example-name
*/

# resource "helm_release" "kubecost" {
#   name             = "kubecost"
#   repository       = "https://kubecost.github.io/cost-analyzer"             
#   chart            = "cost-analyzer"
#   version          = "v1.105.0"
#   namespace        = "kubecost"
#   create_namespace = true

#   #   values = [
#   #   "${file("./helm/kubecost.values.yaml")}"
#   # ]

#   # force_update     = false
#   # recreate_pods    = false # required to read config

# }

