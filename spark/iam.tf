# Create a policy to grant access to the S3 buckets
data "aws_iam_policy_document" "spark_s3_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetObject", "s3:PutObject"]
    resources = [aws_s3_bucket.spark_bucket.arn, "${aws_s3_bucket.spark_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "spark_s3_policy" {
  name   = "SparkS3AccessPolicy"
  policy = data.aws_iam_policy_document.spark_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "spark_s3_policy_role_attachment" {
  policy_arn = aws_iam_policy.spark_s3_policy.arn
  role       = var.nodes_role_name
}
