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

# Create a secret with the AWS connection
resource "aws_secretsmanager_secret" "aws_connection" {
  name = "airflow/connections/aws_s3"

  tags = merge(
    {
      Name     = "Airflow Connection to AWS"
      Variable = "AIRFLOW_CONN_AWS_S3"
    },
    var.global_tags
  )
}

resource "aws_secretsmanager_secret_version" "aws_connection" {
  secret_id     = aws_secretsmanager_secret.aws_connection.id
  secret_string = "aws://"
}
