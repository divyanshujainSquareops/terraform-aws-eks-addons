variable "name" {
  description = "Specify the name prefix of the EKS cluster resources."
  type        = string
  default     = ""
}

variable "cluster_id" {
  description = "Provide name of cluster to take backup."
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region for the EKS cluster"
  default     = "us-east-2"
  type        = string
}

variable "environment" {
  description = "Environment identifier for the EKS cluster"
  default     = ""
  type        = string
}

variable "velero_config" {
  description = "velero configurations"
  type        = any
  default = {
    slack_appToken           = ""
    slack_botToken           = ""
    slack_channel_name       = ""
    retention_period_in_days = 45
    namespaces               = ""
    schedule_cron_time       = ""
    velero_backup_name       = ""
    backup_bucket_name       = ""
  }
}

##

variable "velero_helm_config" {
  description = "Kubernetes Velero Helm Chart config"
  type        = any
  default     = null
}

variable "argocd_manage_add_ons" {
  description = "Enable managing add-on configuration via ArgoCD App of Apps"
  type        = bool
  default     = false
}

variable "velero_irsa_policies" {
  description = "IAM policy ARNs for velero IRSA"
  type        = list(string)
  default     = []
}

variable "velero_backup_s3_bucket" {
  description = "Bucket name for velero bucket"
  type        = string
  default     = ""
}

variable "data_plane_wait_arn" {
  description = "Addon deployment will not proceed until this value is known. Set to node group/Fargate profile ARN to wait for data plane to be ready before provisioning addons"
  type        = string
  default     = ""
}

variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
  default     = null
}

variable "eks_oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  type        = string
  default     = null
}

variable "enable_velero" {
  description = "Enable Kubernetes Dashboard add-on"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}

variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = ""
}

variable "velero_values_yaml" {
  description = "Custom config values for velero helm"
  type        = string
  default     = ""
}

variable "velero_notification_enabled"{
  description = "Enable or disable the notification for velero backup."
  default     = false
  type        = bool
}