resource "aws_key_pair" "dataops_key" {
  key_name   = "aws-infra-key"
  public_key = file("${path.module}/keys/aws-infra-key.pub")
}

# Control Node: Runs the data generator, Prometheus, and Grafana
resource "aws_instance" "control_node" {
  ami                    = "ami-01a00762f46d584a1"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.dataops_key.key_name

  # IAM Instance Profile enables passwordless access to S3 and Athena
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  # 15GB = half the 30GB Free Tier storage limit
  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = file("${path.module}/scripts/install_docker.sh")

  tags = {
    Name = "${var.project_name}-control-node"
  }
}

# Spark Node: Runs the PySpark ETL engine and Node Exporter
resource "aws_instance" "spark_node" {
  ami                    = "ami-01a00762f46d584a1"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.dataops_key.key_name

  # IAM Instance Profile enables PySpark to read/write S3 without access keys
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  # 15GB = the other half of the 30GB Free Tier storage limit
  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = file("${path.module}/scripts/install_docker.sh")

  tags = {
    Name = "${var.project_name}-spark-node"
  }
}
