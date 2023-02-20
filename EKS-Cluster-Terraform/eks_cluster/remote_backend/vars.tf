variable "region" {
  type        = string
  description = "region of the backend s3 bucket for terraform state file"
}

variable "bucket_name" {
  type        = string
  description = "name of the backend s3 bucket for terraform state file"
}

variable "dynamodb_table_name" {
  type        = string
  description = "name of the dynamodb table for terraform state file"
}