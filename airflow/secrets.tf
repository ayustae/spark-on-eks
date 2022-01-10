# Create a secret with the Airflow Fernet Key
data "external" "create_fernet_key" {
  program = ["python", "${path.module}/scripts/create_fernet_key.py"]
  query   = {}
}

resource "aws_secretsmanager_secret" "fernet_key" {
  name = "airflow/config/fernet_key"

  tags = merge(
    {
      Name     = "Airflow Fernet Key"
      Variable = "AIRFLOW__CORE__FERNET_KEY"
    },
    var.global_tags
  )
}

resource "aws_secretsmanager_secret_version" "fernet_key" {
  secret_id     = aws_secretsmanager_secret.fernet_key.id
  secret_string = data.external.create_fernet_key.result.fernet_key
}

# Create a secret with the DB connection string
resource "aws_secretsmanager_secret" "db_conn_string" {
  name = "airflow/config/sql_conn_string"

  tags = merge(
    {
      Name     = "Airflow SQL Connection String"
      Variable = "AIRFLOW__CORE__SQL_ALCHEMY_CONN_STRING"
    },
    var.global_tags
  )
}

resource "aws_secretsmanager_secret_version" "db_conn_string" {
  secret_id     = aws_secretsmanager_secret.db_conn_string.id
  secret_string = "postgresql+psycopg2://${var.db_username}:${var.db_password}@${aws_db_instance.airflow-db.endpoint}/${aws_db_instance.airflow-db.name}"
}

# Create a secret with the Flask webserver secret key
data "external" "create_webserver_secret_key" {
  program = ["python", "${path.module}/scripts/create_webserver_secret_key.py"]
  query   = {}
}

resource "aws_secretsmanager_secret" "webserver_secret_key" {
  name = "airflow/config/secret_key"

  tags = merge(
    {
      Name     = "Airflow Flask Webserver Secret Key"
      Variable = "AIRFLOW__WEBSERVER__SECRET_KEY"
    },
    var.global_tags
  )
}

resource "aws_secretsmanager_secret_version" "webserver_secret_key" {
  secret_id     = aws_secretsmanager_secret.webserver_secret_key.id
  secret_string = data.external.create_webserver_secret_key.result.flask_secret_key
}

# Create a policy to access Secrets Manager
data "aws_iam_policy_document" "access_secrets_manager_document" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionId"
    ]
    resources = [
      aws_secretsmanager_secret.webserver_secret_key.arn,
      aws_secretsmanager_secret.fernet_key.arn,
      aws_secretsmanager_secret.db_conn_string.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "access_secrets_manager" {
  name        = "k8s-spark_access-secret-manager"
  description = "Allow the EKS Cluster access some secrets stored at Secret Manager."
  policy      = data.aws_iam_policy_document.access_secrets_manager_document.json

  tags = merge(
    {
      Name = "Spark on Kubernetes - Access Secret Manager"
    },
    var.global_tags
  )
}

# Attach the policy to the Airflow SA Role
resource "aws_iam_role_policy_attachment" "access_secrets_manager_policy_role_attachment" {
  policy_arn = aws_iam_policy.access_secrets_manager.arn
#  role       = aws_iam_role.airflow_sa_role.name
  role       = var.nodes_role_name
}
