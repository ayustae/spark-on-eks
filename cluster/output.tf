output "kubernetes_cluster_name" {
  value = "spark_k8s_cluster"
}

output "nodes_sg_id" {
  value = aws_security_group.eks_nodes_sg.id
}

output "nodes_role_name" {
  value = aws_iam_role.node_pool_role.name
}
