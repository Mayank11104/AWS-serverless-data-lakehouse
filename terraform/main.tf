resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Raw landing zone: ingests real-time JSON from the data generator
resource "aws_s3_bucket" "raw_landing_zone" {
  bucket        = "${var.project_name}-${var.environment}-raw-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# Curated layer: stores Bronze/Silver/Gold Parquet data transformed by PySpark
resource "aws_s3_bucket" "curated_delta_lake" {
  bucket        = "${var.project_name}-${var.environment}-curated-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# Athena requires a dedicated output bucket for storing query result sets
resource "aws_s3_bucket" "athena_results" {
  bucket        = "${var.project_name}-${var.environment}-athena-results-${random_id.bucket_suffix.hex}"
  force_destroy = true
}
