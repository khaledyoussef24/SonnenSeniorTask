variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Kubernetes namespace to deploy into"
  type        = string
  default     = "nginx-app"
}

variable "release_name" {
  description = "Helm release name for the chart"
  type        = string
  default     = "nginx-app"
}
