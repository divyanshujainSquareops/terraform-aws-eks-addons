locals {
  region      = "us-west-1"
  environment = "prod"
  name        = "addons"
  additional_tags = {
    Owner      = "Organization_Name"
    Expires    = "Never"
    Department = "Engineering"
  }
  ipv6_enabled = false
  cluster-name = "update-eks"
}

module "eks-addons" {
  source           = "../.."
  name             = local.name
  tags             = local.additional_tags
  vpc_id           = "vpc-097830dda1037c6b1"
  environment      = local.environment
  ipv6_enabled     = local.ipv6_enabled
  kms_key_arn      = "arn:aws:kms:us-west-1:767398031518:key/mrk-0ba346007c4a4743bce4f9a4689699ff"
  keda_enabled     = false
  kms_policy_arn   = "arn:aws:iam::767398031518:policy/update-eks-kubernetes-pvc-kms-policy" ## eks module will create kms_policy_arn
  eks_cluster_name = local.cluster-name
  ## Service Monitoring
  service_monitor_crd_enabled = true
  # Config reloader
  reloader_enabled = false
  reloader_helm_config = [
    templatefile("${path.module}/config/reloader.yaml", {
      enable_service_monitor = false # This line applies configurations only when ADDONS "service_monitor_crd_enabled" is set to false.
    })
  ]
  kubernetes_dashboard_enabled        = false
  k8s_dashboard_ingress_load_balancer = "" ##Choose your load balancer type (e.g., NLB or ALB). If using ALB, ensure you provide the ACM certificate ARN for SSL.
  alb_acm_certificate_arn             = ""
  k8s_dashboard_hostname              = "dashboard.prod.in"
  ## aws load balancer controller
  aws_load_balancer_controller_enabled = false
  aws_load_balancer_controller_helm_config = {
    values = [
      file("${path.module}/config/aws-alb.yaml")
    ]
  }
  # karpenter_enabled                       = false
  # karpenter_helm_config = {
  #   values = [
  #     templatefile("${path.module}/config/karpenter.yaml", {
  #       eks_cluster_id            = local.cluster-name,
  #       # eks_cluster_endpoint      = data.aws_eks_cluster.eks.endpoint
  #       node_iam_instance_profile = "" # enter profile for 
  #     })
  #   ]
  # }

  private_subnet_ids                      = ["subnet-0efd4453a4b9fe5de", "subnet-0cad3a38f5881e55d"]
  single_az_ebs_gp3_storage_class_enabled = true
  single_az_sc_config                     = [{ name = "infra-service-sc", zone = "${local.region}a" }]
  # coredns HPA
  coredns_hpa_enabled = false
  coredns_hpa_helm_config = {
    values = [
      file("${path.module}/config/coredns_hpa.yaml")
    ]
  }
  kubeclarity_enabled  = false
  kubeclarity_hostname = "kubeclarity.prod.in"
  kubecost_enabled     = false
  kubecost_hostname    = "kubecost.prod.in"
  defectdojo_enabled   = false
  defectdojo_hostname  = "defectdojo.prod.in"
  ## Cert_Manager
  cert_manager_enabled = false
  cert_manager_helm_config = {
    values = [
      file("${path.module}/config/cert-manager.yaml")
    ]
  }
  cert_manager_install_letsencrypt_http_issuers = false
  cert_manager_letsencrypt_email                = "email@email.com"

  worker_iam_role_name  = "update-eks-node-role"
  worker_iam_role_arn   = "arn:aws:iam::767398031518:role/update-eks-node-role"
  ingress_nginx_enabled = false
  ## Metric Server
  metrics_server_enabled     = false
  metrics_server_helm_config = [file("${path.module}/config/metrics-server.yaml")]
  ## External Secrets
  external_secrets_enabled = false
  external_secrets_helm_config = {
    values = [file("${path.module}/config/external-secret.yaml")
    ]
  }
  ## cluster autoscaler
  cluster_autoscaler_enabled = false
  cluster_autoscaler_helm_config = [
    templatefile("${path.module}/config/cluster-autoscaler.yaml", {
      aws_region     = local.region
      eks_cluster_id = local.cluster-name
  })]

  falco_enabled = false
  slack_webhook = "xoxb-379541400966-iibMHnnoaPzVl"
  istio_enabled = false
  istio_config = {
    ingress_gateway_enabled       = false
    egress_gateway_enabled        = false
    envoy_access_logs_enabled     = false
    prometheus_monitoring_enabled = false
    istio_values_yaml             = file("./config/istio.yaml")
  }
  karpenter_provisioner_enabled = true
  karpenter_provisioner_config = {
    private_subnet_name    = "${local.environment}-${local.name}-private-subnet"
    instance_capacity_type = ["spot"]
    excluded_instance_type = ["nano", "micro", "small"]
    instance_hypervisor    = ["nitro"]
  }

  internal_ingress_nginx_enabled = false
  # ingress_nginx_helm_config = {
  #   version = "4.9.1"
  #   ingress_values_yaml = templatefile("${path.module}/config/${data.aws_eks_cluster.eks.kubernetes_network_config[0].ip_family == "ipv4" ? "nginx_ingress.yaml" : "nginx_ingress_ipv6.yaml"}" , { enable_service_monitor = false }) 
  # }
  efs_storage_class_enabled = false
  #Node termination handler
  aws_node_termination_handler_enabled = false
  aws_node_termination_handler_helm_config = [
    templatefile("${path.module}/config/aws-node-termination-handler.yaml", {
      enable_service_monitor = false # This line applies configurations only when ADDONS "service_monitor_crd_enabled" is set to false.
    })
  ]

  velero_notification_enabled = true
  velero_enabled              = true
  velero_config = {
    namespaces                      = "" ## If you want full cluster backup, leave it blank else provide namespace.
    slack_botToken                  = "xoxb-xxxx-xxxx-xxxx"
    slack_appToken                  = "xapp-1-xxxx-12345-abcdef"
    slack_notification_channel_name = "atmosly-notifications"
    retention_period_in_days        = 45
    schedule_backup_cron_time       = "* 6 * * *"
    velero_backup_name              = "application-backup"
    backup_bucket_name              = "velero-bck"
    velero_values_yaml = [file("${path.module}/config/velero.yaml")]
  }
}
