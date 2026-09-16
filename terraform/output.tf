output "ansible_controller_id" {
  value = aws_instance.ansible_controller.id
}

output "jenkins_master_id" {
  value = aws_instance.devops_jenkins_master.id
}

output "jenkins_agents_ids" {
  value = aws_instance.devops_jenkins_agent[*].id
}

output "private_ips" {
  value = {
    ansible_controller = aws_instance.ansible_controller.private_ip
    jenkins_master     = aws_instance.devops_jenkins_master.private_ip
    jenkins_agents     = aws_instance.devops_jenkins_agent[*].private_ip
  }
}
