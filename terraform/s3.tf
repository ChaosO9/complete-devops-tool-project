resource "aws_s3_bucket" "devops_ansible_bucket" {
  bucket = "devops-ansible-bucket-irfan"
}

resource "aws_s3_bucket_versioning" "devops_ansible_bucket_versioning" {
  bucket = aws_s3_bucket.devops_ansible_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "devops_s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.devops_ansible_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
