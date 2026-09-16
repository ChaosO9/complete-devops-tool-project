resource "aws_security_group" "devops_security_group" {
  name        = "devops-security-group"
  description = "Allow all egress access"
  vpc_id      = aws_vpc.devops_vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
