resource "aws_s3_bucket" "terraform-state-storage" {
    bucket = "${var.bucket_name}"

    versioning {
      enabled = true
    }

    lifecycle {
      prevent_destroy = true
    }

    tags {
      Name = "${var.bucket_name}"
    }
}

resource "aws_dynamodb_table" "terraform-state-lock" {
  name = "${var.table_name}"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name = "${var.table_name}"
  }
}
