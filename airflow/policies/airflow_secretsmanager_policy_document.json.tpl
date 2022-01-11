{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GetSecretInformation",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionId"
            ],
            "Resource": "${airflow_secretsmanager_arn}"
        },
        {
            "Sid": "ListSecrets",
            "Effect": "Allow",
            "Action": "secretsmanager:ListSecrets",
            "Resource": "*"
        }
    ]
}
