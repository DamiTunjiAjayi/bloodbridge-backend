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

  # Attributes for GSI
  attribute {
    name = "conversationId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  # ConversationId GSI
  global_secondary_index {
    name               = "ConversationIdIndex"
    hash_key           = "conversationId"
    range_key          = "timestamp"
    projection_type    = "ALL"
    write_capacity     = 5
    read_capacity      = 5
  }

  # TTL configuration
  ttl {
    attribute_name = "expiry"
    enabled        = true
  }

  tags = {
    Name        = "${var.RESOURCES_PREFIX}-${var.table_name}"
    Environment = var.ENV
  }
}