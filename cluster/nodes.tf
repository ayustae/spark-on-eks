# Create an IAM Role for the EKS Nodes
resource "aws_iam_role" "node_pool_role" {
  name = "spark_k8s_cluster_nodes_role"

  assume_role_policy = file("${path.module}/policies/ec2_assumerole_policy.json")
}

# Policy attachments for the EKS Nodes IAM Role
resource "aws_iam_role_policy_attachment" "managed_eks_worker_policy_to_node_pool_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_pool_role.name
}

resource "aws_iam_role_policy_attachment" "managed_eks_cni_policy_to_node_pool_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_pool_role.name
}

resource "aws_iam_role_policy_attachment" "managed_ecr_readonly_policy_to_node_pool_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_pool_role.name
}

# Get the RHEL 8 AMI information
data "aws_ami" "rhel8" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-8.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Worker nodes launch template
resource "aws_launch_template" "spark_k8s_cluster_node_group_launch_template" {
  name                   = "spark_k8s_cluster_launch_template"
  description            = "Launch tempalte for the spark_k8s_cluster EKS cluster."
  ebs_optimized          = true
  image_id               = data.aws_ami.rhel8.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.eks_nodes_sg.id]
  user_data              = base64encode(file("${path.module}/scripts/init_script.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Cluster           = "spark_k8s_cluster"
        "Node Group"      = "spark_k8s_cluster_node_group"
        "Launch Template" = "spark_k8s_cluster_launch_template"
      },
      var.global_tags
    )
  }

  tags = merge(
    {
      Name         = "Spark Kubernetes Cluster Launch Template"
      Cluster      = "spark_k8s_cluster"
      "Node Group" = "spark_k8s_cluster_node_group"
    },
    var.global_tags
  )
}

# Create a node group for the EKS cluster
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.k8s_cluster.name
  node_group_name = "spark_k8s_cluster_node_group"
  node_role_arn   = aws_iam_role.node_pool_role.arn
  subnet_ids      = var.private_subnets_ids

  launch_template {
    id      = aws_launch_template.spark_k8s_cluster_node_group_launch_template.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.node_group_desired
    max_size     = var.node_group_max
    min_size     = var.node_group_min
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(
    {
      Name    = "Spark Kubernetes Cluster Main Node Pool"
      Cluster = aws_eks_cluster.k8s_cluster.name
    },
    var.global_tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.managed_eks_worker_policy_to_node_pool_role_attachment,
    aws_iam_role_policy_attachment.managed_eks_cni_policy_to_node_pool_role_attachment,
    aws_iam_role_policy_attachment.managed_ecr_readonly_policy_to_node_pool_role_attachment
  ]
}
