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

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # 1. Ensure filesystem uses full EBS size
              growpart /dev/nvme0n1 1 || true
              resize2fs /dev/nvme0n1p1 || true

              # 2. Configure 4GB Swapfile
              if [ ! -f /swapfile ]; then
                fallocate -l 4G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile
                echo '/swapfile none swap sw 0 0' >> /etc/fstab
              fi

              # 3. Disable tmpfs mount so /tmp uses the 30GB EBS disk
              systemctl mask tmp.mount
              systemctl stop tmp.mount || true
              EOF
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
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # 1. Ensure filesystem uses full EBS size
              growpart /dev/nvme0n1 1 || true
              resize2fs /dev/nvme0n1p1 || true

              # 2. Configure 4GB Swapfile
              if [ ! -f /swapfile ]; then
                fallocate -l 4G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile
                echo '/swapfile none swap sw 0 0' >> /etc/fstab
              fi

              # 3. Disable tmpfs mount so /tmp uses the 30GB EBS disk
              systemctl mask tmp.mount
              systemctl stop tmp.mount || true
              EOF
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

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  depends_on = [aws_s3_object.ansible_inventory]

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # 0. Configure 4GB Swapfile
              if [ ! -f /swapfile ]; then
                fallocate -l 4G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile
                echo '/swapfile none swap sw 0 0' >> /etc/fstab
              fi

              # 0.1 Disable tmpfs mount so /tmp uses the 30GB EBS disk
              systemctl mask tmp.mount
              systemctl stop tmp.mount || true

              # 1. Update and install packages
              apt-get update -y
              apt-get install -y python3-pip ansible awscli curl git

              # 2. Install boto3 and botocore
              pip3 install boto3 botocore

              # 3. Install AWS Session Manager Plugin (ARM64)
              curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb"
              dpkg -i /tmp/session-manager-plugin.deb
              rm -f /tmp/session-manager-plugin.deb

              # 4. Install Ansible community.aws collection system-wide
              ansible-galaxy collection install community.aws -p /usr/share/ansible/collections

              # 5. Clone repository and set up playbooks
              sudo -u ubuntu git clone https://github.com/ChaosO9/complete-devops-tool-project.git /home/ubuntu/complete-devops-tool-project || true

              # 6. Download inventory.ini from S3 into home and repo
              aws s3 cp s3://${aws_s3_bucket.devops_ansible_bucket.bucket}/inventory.ini /home/ubuntu/inventory.ini
              cp /home/ubuntu/inventory.ini /home/ubuntu/complete-devops-tool-project/ansible/inventory.ini || true

              # 7. Set correct permissions for ubuntu user
              chown -R ubuntu:ubuntu /home/ubuntu
              EOF
}
