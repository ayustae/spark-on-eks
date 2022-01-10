# Create an IAM Role for EKS
resource "aws_iam_role" "eks_role" {
  name = "spark_k8s_cluster_role"

  assume_role_policy = file("${path.module}/policies/eks_assumerole_policy.json")
}

# Policy attachments for the EKS IAM Role
resource "aws_iam_role_policy_attachment" "managed_eks_policy_to_eks_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# Create the EKS cluster
resource "aws_eks_cluster" "k8s_cluster" {
  name     = "spark_k8s_cluster"
  role_arn = aws_iam_role.eks_role.arn
  #enabled_cluster_log_types = [""]

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    subnet_ids              = flatten([var.public_subnets_ids, var.private_subnets_ids])
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.eks_service_cidr
  }

  tags = merge(
    {
      Name = "Spark Kubernetes Cluster"
    },
    var.global_tags
  )

  depends_on = [aws_iam_role_policy_attachment.managed_eks_policy_to_eks_role_attachment]
}

# Create an OpenID Connect provider for the cluster
data "tls_certificate" "k8s_cluster_tls_certificate" {
  url = aws_eks_cluster.k8s_cluster.identity[0].oidc[0].issuer
}
