#
# RKE2 Cluster
#
output "kubeconfig_path" {
  description = "Path to kubeconfig in S3"
  value       = module.rke2.kubeconfig_path
}
