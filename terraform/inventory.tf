resource "aws_s3_object" "ansible_inventory" {
  bucket = aws_s3_bucket.devops_ansible_bucket.bucket
  key    = "inventory.ini"

  content = <<-EOT
[jenkins_master]
${aws_instance.devops_jenkins_master.id}

[jenkins_agents]
%{for id in aws_instance.devops_jenkins_agent[*].id~}
${id}
%{endfor~}

[all:vars]
ansible_connection=community.aws.aws_ssm
ansible_aws_ssm_region=${var.aws_region}
ansible_aws_ssm_bucket_name=${aws_s3_bucket.devops_ansible_bucket.bucket}
ansible_aws_ssm_timeout=600
ansible_command_timeout=600
jenkins_master_ip=${aws_instance.devops_jenkins_master.private_ip}
EOT
}
