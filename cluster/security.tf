# Security group for the EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "spark-k8s-cluster-sg"
  description = "Security Group for the NIC used by the nodes to talk to the k8s control plane."
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow worker nodes to talk to the control plane."
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }

  egress {
    description     = "Allow the control plane to talk to the worker nodes."
    protocol        = "tcp"
    from_port       = 1024
    to_port         = 65535
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }

  tags = merge(
    {
      Name = "Spark Kuberentes Cluster Security Group"
    },
    var.global_tags
  )
}

# Security group for the EKS nodes
resource "aws_security_group" "eks_nodes_sg" {
  name        = "spark-k8s-cluster-node-pool-sg"
  description = "Security Group for the worker nodes of the EKS cluster."
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow nodes to talk to each other."
    protocol        = "-1"
    from_port       = 0
    to_port         = 65535
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }

  ingress {
    description     = "Allow nodes to be talk by the control plane."
    protocol        = "tcp"
    from_port       = 1025
    to_port         = 65535
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  egress {
    description = "Allow access to everything everywhere."
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "Spark Kubernetes Cluster Worker Nodes Security Group"
    },
    var.global_tags
  )
}
