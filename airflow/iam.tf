# Get the account id
data "aws_caller_identity" "caller_id" {}

# Create a plicy to grant access to the S3 buckets
data "aws_iam_policy_document" "airflow_s3_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetObject", "s3:PutObject"]
    resources = [aws_s3_bucket.airflow_logs.arn, "${aws_s3_bucket.airflow_logs.arn}/*", aws_s3_bucket.airflow_dags.arn, "${aws_s3_bucket.airflow_dags.arn}/*"]
  }
}

resource "aws_iam_policy" "airflow_s3_policy" {
  name   = "S3SyncPolicy"
  policy = data.aws_iam_policy_document.airflow_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "airflow_s3_policy_role_attachment" {
  policy_arn = aws_iam_policy.airflow_s3_policy.arn
  role       = var.nodes_role_name
}

# Create a policy to grant access to Secrets Manager
#data "aws_iam_policy_document" "airflow_secretsmanager_policy_document" {
#  statement {
#    effect = "Allow"
#    actions = [
#      "secretsmanager:GetResourcePolicy",
#      "secretsmanager:GetSecretValue",
#      "secretsmanager:DescribeSecret",
#      "secretsmanager:ListSecretVersionId"
#    ]
#    resources = [
#      aws_secretsmanager_secret.webserver_secret_key.arn,
#      aws_secretsmanager_secret.fernet_key.arn,
#      aws_secretsmanager_secret.db_conn_string.arn
#    ]
#  }
#
#  statement {
#    effect = "Allow"
#    actions = [
#      "secretsmanager:ListSecrets"
#    ]
#    resources = ["*"]
#  }
#}

data "template_file" "airflow_secretsmanager_policy_document" {
  template = file("${path.module}/policies/airflow_secretsmanager_policy_document.json.tpl")

  vars = {
    airflow_secretsmanager_arn = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.caller_id.account_id}:secret:airflow/*"
  }
}

resource "aws_iam_policy" "airflow_secretsmanager_policy" {
  name        = "AirflowSecretsManagerPolicy"
  description = "Allow the EKS Cluster access some secrets stored at Secret Manager."
#  policy      = data.aws_iam_policy_document.airflow_secretsmanager_policy_document.json
  policy      = data.template_file.airflow_secretsmanager_policy_document.rendered

  tags = merge(
    {
      Name = "Spark on Kubernetes - Access Secret Manager"
    },
    var.global_tags
  )
}

resource "aws_iam_role_policy_attachment" "airflow_secretsmanager_policy_role_attachment" {
  policy_arn = aws_iam_policy.airflow_secretsmanager_policy.arn
  role       = var.nodes_role_name
}

