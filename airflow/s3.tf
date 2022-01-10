# Create an S3 bucket for the Airflow logs
resource "aws_s3_bucket" "airflow_logs" {
  bucket = "sdg-tht-airflow-logs"

  lifecycle_rule {
    id      = "recycle-logs"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 60
    }
  }

  tags = merge(
    {
      Name = "Airflow Logs"
    },
    var.global_tags
  )
}

# Create an S3 bucket for the Airflow dags
resource "aws_s3_bucket" "airflow_dags" {
  bucket = "sdg-tht-airflow-dags"

  tags = merge(
    {
      Name = "Airflow DAGs"
    },
    var.global_tags
  )
}
