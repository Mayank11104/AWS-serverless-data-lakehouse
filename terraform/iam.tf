# IAM Role for EC2 to assume
resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.project_name}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Policy allowing Write Access to the Raw Bucket
resource "aws_iam_policy" "s3_write_policy" {
  name        = "${var.project_name}-s3-write-policy"
  description = "Allows EC2 to write JSON data to the raw landing S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.raw_landing_zone.arn,
          "${aws_s3_bucket.raw_landing_zone.arn}/*",
          aws_s3_bucket.curated_delta_lake.arn,
          "${aws_s3_bucket.curated_delta_lake.arn}/*",
          aws_s3_bucket.athena_results.arn,
          "${aws_s3_bucket.athena_results.arn}/*"
        ]
      },
      {
        Action   = [
          "athena:*",
          "glue:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ec2_s3_attach" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

# Instance Profile (This is what actually gets attached to the EC2 instance)
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_s3_role.name
}
