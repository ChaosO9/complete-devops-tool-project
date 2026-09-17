resource "aws_instance" "devops_jenkins_agent" {
  count                  = var.jenkins_agent_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.devops_private_subnet.id
  vpc_security_group_ids = [aws_security_group.devops_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  tags = {
    Name = "jenkins-agent-${count.index + 1}"
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = "persistent"
      instance_interruption_behavior = "stop"
    }
  }
}

resource "aws_ebs_volume" "jenkins_master_storage" {
  availability_zone = aws_subnet.devops_private_subnet.availability_zone
  size              = 30
  type              = "gp3"

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_instance" "devops_jenkins_master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.devops_private_subnet.id
  vpc_security_group_ids = [aws_security_group.devops_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  tags = {
    Name = "jenkins-master"
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = "persistent"
      instance_interruption_behavior = "stop"
    }
  }
}

resource "aws_volume_attachment" "jenkins_master_volume_attachment" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.devops_jenkins_master.id
  volume_id   = aws_ebs_volume.jenkins_master_storage.id
}

resource "aws_instance" "ansible_controller" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.devops_private_subnet.id
  vpc_security_group_ids = [aws_security_group.devops_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  tags = {
    Name = "ansible-controller"
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = "persistent"
      instance_interruption_behavior = "stop"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y python3-pip ansible
              pip3 install boto3 botocore
              ansible-galaxy collection install community.aws
              aws s3 cp s3://${aws_s3_bucket.devops_ansible_bucket.bucket}/inventory.ini /home/ubuntu/inventory.ini
              chown ubuntu:ubuntu /home/ubuntu/inventory.ini
              EOF
}
