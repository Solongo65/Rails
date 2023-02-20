provider "aws" {
  region = var.region
}

### S3
resource "aws_s3_bucket" "tf_remote_state" {
  bucket = var.bucket_name
  force_destroy = true
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
}

# Dynamodb lock
resource "aws_dynamodb_table" "tf_remote_state_locking" {
  hash_key = "LockID"
  name = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }  
}