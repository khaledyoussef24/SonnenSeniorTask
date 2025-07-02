resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "nginx" {
  name       = var.release_name
  namespace  = kubernetes_namespace.app.metadata[0].name
  chart      = "../charts/nginx"
  values     = [file("${path.module}/helm_values.yaml")]
  timeout    = 300
  atomic     = true
}
