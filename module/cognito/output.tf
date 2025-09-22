output "COGNITO_USER_POOL_ARN" {
  value = aws_cognito_user_pool.congito_end_user_userpool.arn
}


output "COGNITO_USER_POOL_ID" {
  value = aws_cognito_user_pool.congito_end_user_userpool.id
}
output "COGNITO_USER_CLIENT_SECRET" {
  value = aws_cognito_user_pool_client.cognito_client_end_user.client_secret
}

output "COGNITO_USER_CLIENT_ID" {
  value = aws_cognito_user_pool_client.cognito_client_end_user.id
}
