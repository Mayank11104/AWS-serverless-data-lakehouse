# Create an IAM User specifically for Databricks to use
resource "aws_iam_user" "databricks_user" {
  name = "${var.project_name}-databricks-worker"
}

# Generate Access Keys for this user
resource "aws_iam_access_key" "databricks_key" {
  user = aws_iam_user.databricks_user.name
}

# Create a Policy that allows reading the Raw bucket and writing to the Curated bucket
resource "aws_iam_policy" "databricks_s3_policy" {
  name        = "${var.project_name}-databricks-s3-policy"
  description = "Allows Databricks PySpark to read Raw JSON and write Delta Tables"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.raw_landing_zone.arn,
          "${aws_s3_bucket.raw_landing_zone.arn}/*",
          aws_s3_bucket.curated_delta_lake.arn,
          "${aws_s3_bucket.curated_delta_lake.arn}/*"
        ]
      }
    ]
  })
}

# Attach the Policy to the Databricks User
resource "aws_iam_user_policy_attachment" "databricks_s3_attach" {
  user       = aws_iam_user.databricks_user.name
  policy_arn = aws_iam_policy.databricks_s3_policy.arn
}

# Output the keys so you can copy them into Databricks
output "databricks_access_key_id" {
  description = "Access Key for Databricks"
  value       = aws_iam_access_key.databricks_key.id
}

output "databricks_secret_access_key" {
  description = "Secret Key for Databricks (Run 'terraform output databricks_secret_access_key' to see it)"
  value       = aws_iam_access_key.databricks_key.secret
  sensitive   = true
}
