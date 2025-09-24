provider "aws" {
  region = "ap-south-1"
}

variable "tf_state_bucket" {
  type        = string
  default     = "tf-state-kishorebskr-qw-final4"   #  fixed, all lowercase, globally unique
  description = "S3 bucket name for Terraform remote state"
}

variable "tf_lock_table" {
  type        = string
  default     = "tf-state-locks-kishorebskr-qw-final4"   #  fixed lock table name
  description = "DynamoDB table name for Terraform state locking"
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "tf_state" {
  bucket = var.tf_state_bucket

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "tf_locks" {
  name         = var.tf_lock_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}