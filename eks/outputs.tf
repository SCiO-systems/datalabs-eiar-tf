output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "kubeconfig" {
  value = "aws eks --region ${var.region} update-kubeconfig --name ${aws_eks_cluster.eks-cluster.name}"
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.eks-cluster.vpc_config[0].cluster_security_group_id
}