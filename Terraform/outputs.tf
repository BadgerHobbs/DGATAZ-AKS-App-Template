# Print external IP address of application
output "dgataz_aks_app_external_ip" {
  description = "The external IP address of the app service"
  value       = kubernetes_service.dgataz_aks_app.status[0].load_balancer[0].ingress[0].ip
}
