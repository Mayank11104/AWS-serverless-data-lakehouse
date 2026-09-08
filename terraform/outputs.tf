output "raw_bucket_name" {
  description = "The name of the raw landing S3 bucket"
  value       = aws_s3_bucket.raw_landing_zone.bucket
}

output "curated_bucket_name" {
  description = "The name of the curated delta lake S3 bucket"
  value       = aws_s3_bucket.curated_delta_lake.bucket
}

output "control_node_public_ip" {
  description = "Public IP of the Control Node (Grafana/Prometheus/Generator)"
  value       = aws_instance.control_node.public_ip
}

output "spark_node_public_ip" {
  description = "Public IP of the Spark Engine Node (Jupyter/PySpark)"
  value       = aws_instance.spark_node.public_ip
}

output "spark_node_private_ip" {
  description = "Private IP of the Spark Engine Node (Used by Prometheus for scraping)"
  value       = aws_instance.spark_node.private_ip
}
