# Upload the local SSH public key to AWS
resource "aws_key_pair" "dataops_key" {
  key_name   = "aws-infra-key"
  public_key = file("${path.module}/keys/aws-infra-key.pub")
}

# Provision the Control Node (Monitoring + Data Gen)
resource "aws_instance" "control_node" {
  ami                    = "ami-01a00762f46d584a1"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Attach the SSH key pair
  key_name               = aws_key_pair.dataops_key.key_name 

  # Attach the IAM Instance Profile so it can securely access S3 (for the data generator)
  iam_instance_profile   = aws_iam_instance_profile.ec2_s3_profile.name

  # Allocate 15GB (Half of our 30GB Free Tier limit)
  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Automatically install Docker and Docker-Compose on boot from file
  user_data = file("${path.module}/scripts/install_docker.sh")

  tags = {
    Name = "${var.project_name}-control-node"
  }
}

# Provision the Spark Node (Lakehouse Engine)
resource "aws_instance" "spark_node" {
  ami                    = "ami-01a00762f46d584a1"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Attach the SSH key pair
  key_name               = aws_key_pair.dataops_key.key_name 

  # Attach the IAM Instance Profile so PySpark can read/write to S3
  iam_instance_profile   = aws_iam_instance_profile.ec2_s3_profile.name

  # Allocate 15GB (The other half of our 30GB Free Tier limit)
  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Automatically install Docker and Docker-Compose on boot from file
  user_data = file("${path.module}/scripts/install_docker.sh")

  tags = {
    Name = "${var.project_name}-spark-node"
  }
}
