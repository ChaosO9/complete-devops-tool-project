resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory.ini"

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
EOT
}
