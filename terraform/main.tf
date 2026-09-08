resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 1. Raw Landing Bucket (Where the Python generator will dump JSONs)
resource "aws_s3_bucket" "raw_landing_zone" {
  bucket        = "${var.project_name}-${var.environment}-raw-${random_id.bucket_suffix.hex}"
  force_destroy = true # Allows Terraform to delete the bucket even if it has data (useful for dev)
}

# 2. Curated Delta Lake Bucket (Where Databricks will store Bronze/Silver/Gold tables)
resource "aws_s3_bucket" "curated_delta_lake" {
  bucket        = "${var.project_name}-${var.environment}-curated-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# 3. Athena Query Results Bucket (Required by AWS Athena)
resource "aws_s3_bucket" "athena_results" {
  bucket        = "${var.project_name}-${var.environment}-athena-results-${random_id.bucket_suffix.hex}"
  force_destroy = true
}
