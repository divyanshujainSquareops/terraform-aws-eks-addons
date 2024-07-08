resource "helm_release" "vpa-crds" {
  name       = "vertical-pod-autoscaler"
  namespace  = "kube-system"
  repository = "https://cowboysysop.github.io/charts/"
  chart      = "vertical-pod-autoscaler"
  version    = "9.8.2"
  timeout    = 600
  values = [
    file("${path.module}/config/values.yaml"),
      var.helm-config
  ]
}