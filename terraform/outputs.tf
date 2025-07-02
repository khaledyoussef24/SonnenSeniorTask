data "kubernetes_service" "nginx" {
  metadata {
    name      = var.release_name
    namespace = var.namespace
  }
  depends_on = [
    helm_release.nginx
  ]
}

output "service_cluster_ip" {
  description = "ClusterIP of the nginx service"
  value       = data.kubernetes_service.nginx.spec[0].cluster_ip
}
