# Security Group for the Airflow DB
resource "aws_security_group" "airflow-db-sg" {
  name        = "spark-k8s-cluster-airflow-db-sg"
  description = "Security Group for the Airflow DB."
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow connections to port 5432 from the k8s nodes."
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.nodes_security_group_id]
  }

  tags = merge(
    {
      Name = "Spark Kubernetes Cluster Airflow DB Security Group"
    },
    var.global_tags
  )
}

# Create a DB for Airflow
resource "aws_db_instance" "airflow-db" {
  identifier                  = "airflow-db"
  engine                      = "postgres"
  engine_version              = ""
  name                        = "airflow"
  instance_class              = var.db_instance_type
  max_allocated_storage       = var.db_size
  allocated_storage           = 20
  allow_major_version_upgrade = true
  multi_az                    = false
  username                    = var.db_username
  password                    = var.db_password
  publicly_accessible         = false
  skip_final_snapshot         = true
  storage_encrypted           = true
  db_subnet_group_name        = var.db_subnet_group
  vpc_security_group_ids      = [aws_security_group.airflow-db-sg.id]

  tags = merge(
    {
      Name = "Aiflow DB"
    },
    var.global_tags
  )
}
