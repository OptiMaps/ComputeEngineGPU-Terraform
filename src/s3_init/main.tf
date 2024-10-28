resource "aws_s3_bucket" "tfstate-bucket" {
  bucket = "sangylee-s3-bucket-tfstate"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "test-versioning" {
  bucket = aws_s3_bucket.tfstate-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-tfstate-lock"
  hash_key       = "LockID"
  read_capacity = 2
  write_capacity = 2

  attribute {
    name = "LockID"
    type = "S"
  }
}