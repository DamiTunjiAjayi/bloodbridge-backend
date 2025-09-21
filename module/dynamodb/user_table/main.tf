resource "aws_dynamodb_table" "dynamodb-table" {
  name           = "${var.RESOURCES_PREFIX}-${var.table_name}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "pk"
  range_key      = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  tags = {
    Name        = "${var.RESOURCES_PREFIX}-${var.table_name}"
    Environment = var.ENV
  }
}