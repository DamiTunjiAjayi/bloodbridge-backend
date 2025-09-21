# =================================================================
#  SIGNUP
# =================================================================
output "LAMBDA_SIGN_UP_FUNCTION_ARN" {
  value = aws_lambda_function.sign_up_function.arn
}
output "LAMBDA_SIGN_UP_FUNCTION_NAME" {
  value = aws_lambda_function.sign_up_function.function_name
}

# =================================================================
#  RESEND_CODE
# =================================================================
output "LAMBDA_RESEND_CODE_FUNCTION_ARN" {
  value = aws_lambda_function.resend_code_function.arn
}
output "LAMBDA_RESEND_CODE_FUNCTION_NAME" {
  value = aws_lambda_function.resend_code_function.function_name
}

# =================================================================
#  LOGIN
# =================================================================
output "LAMBDA_LOGIN_FUNCTION_ARN" {
  value = aws_lambda_function.login_function.arn
}
output "LAMBDA_LOGIN_FUNCTION_NAME" {
  value = aws_lambda_function.login_function.function_name
}

# =================================================================
#  VERIFY_ACCOUNT
# =================================================================
output "LAMBDA_VERIFY_ACCOUNT_FUNCTION_ARN" {
  value = aws_lambda_function.verify_account_function.arn
}
output "LAMBDA_VERIFY_ACCOUNT_FUNCTION_NAME" {
  value = aws_lambda_function.verify_account_function.function_name
}

# =================================================================
#  CHANGE_PASSWORD
# =================================================================
output "LAMBDA_CHANGE_PASSWORD_FUNCTION_ARN" {
  value = aws_lambda_function.change_password_function.arn
}
output "LAMBDA_CHANGE_PASSWORD_FUNCTION_NAME" {
  value = aws_lambda_function.change_password_function.function_name
}

# =================================================================
#  FORGOT_PASSWORD
# =================================================================
output "LAMBDA_FORGOT_PASSWORD_FUNCTION_ARN" {
  value = aws_lambda_function.forgot_password_function.arn
}
output "LAMBDA_FORGOT_PASSWORD_FUNCTION_NAME" {
  value = aws_lambda_function.forgot_password_function.function_name
}

# =================================================================
#  CONFIRM_FORGOT_PASSWORD
# =================================================================
output "LAMBDA_CONFIRM_FORGOT_PASSWORD_FUNCTION_ARN" {
  value = aws_lambda_function.confirm_forgot_password_function.arn
}
output "LAMBDA_CONFIRM_FORGOT_PASSWORD_FUNCTION_NAME" {
  value = aws_lambda_function.confirm_forgot_password_function.function_name
}

# =================================================================
#  CONFIRM_SIGNUP
# =================================================================
output "LAMBDA_CONFIRM_SIGNUP_FUNCTION_ARN" {
  value = aws_lambda_function.confirm_signup_function.arn
}
output "LAMBDA_CONFIRM_SIGNUP_FUNCTION_NAME" {
  value = aws_lambda_function.confirm_signup_function.function_name
}
