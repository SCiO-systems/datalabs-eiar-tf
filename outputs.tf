output "cluster_endpoint" {
  description = "endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "cluster name"
  value       = module.eks.cluster_name
}

output "kubeconfig" {
  description = "fetch kubeconfig"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
}
