# Create an S3 bucket for the Spark job
resource "aws_s3_bucket" "spark_bucket" {
  bucket = "tht-spark"

  tags = merge(
    {
      Name = "Spark job bucket"
    },
    var.global_tags
  )
}

# Create folders on the Spark bucket
resource "aws_s3_bucket_object" "input_folder" {
  bucket       = aws_s3_bucket.spark_bucket.id
  key          = "input/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "output_folder" {
  bucket       = aws_s3_bucket.spark_bucket.id
  key          = "output/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "executables_folder" {
  bucket       = aws_s3_bucket.spark_bucket.id
  key          = "executables/"
  content_type = "application/x-directory"
}
