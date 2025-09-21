# =================================================================
#  SIGNUP  ROLE
# =================================================================
output "SIGN_UP_FUNCTION_ROLE_ARN" {
  value = aws_iam_role.sign_up_function_role.arn
}
output "SIGN_UP_FUNCTION_ROLE_NAME" {
  value = aws_iam_role.sign_up_function_role.name
}

# =================================================================
#  RESEND_CODE  ROLE
# =================================================================
output "RESEND_CODE_FUNCTION_ROLE_ARN" {
  value = aws_iam_role.resend_code_function_role.arn
}
output "RESEND_CODE_FUNCTION_ROLE_NAME" {
  value = aws_iam_role.resend_code_function_role.name
}

# =================================================================
#  LOGIN  ROLE
# =================================================================
output "LOGIN_FUNCTION_ROLE_ARN" {
  value = aws_iam_role.login_function_role.arn
}
output "LOGIN_FUNCTION_ROLE_NAME" {
  value = aws_iam_role.login_function_role.name
}

# =================================================================
#  VERIFY_ACCOUNT  ROLE
# =================================================================
output "VERIFY_ACCOUNT_FUNCTION_ROLE_ARN" {
  value = aws_iam_role.verify_account_function_role.arn
}
output "VERIFY_ACCOUNT_FUNCTION_ROLE_NAME" {
  value = aws_iam_role.verify_account_function_role.name
}

# =================================================================
#  CHANGE_PASSWORD  ROLE
# =================================================================
output "CHANGE_PASSWORD_FUNCTION_ROLE_ARN" {
  value = aws_iam_role.change_password_function_role.arn
}
output "CHANGE_PASSWORD_FUNCTION_ROLE_NAME" {
  value = aws_iam_role.change_password_function_role.name
}

# =================================================================
#  FORGOT_PASSWORD ROLE
# =================================================================
output "FORGOT_PASSWORD_FUNCTION_ROLE_ARN" {
  value = aws_iam_role.forgot_password_function_role.arn
}
output "FORGOT_PASSWORD_FUNCTION_ROLE_NAME" {
  value = aws_iam_role.forgot_password_function_role.name
}

# =================================================================
#  CONFIRM_FORGOT_PASSWORD  ROLE
# =================================================================
output "CONFIRM_FORGOT_PASSWORD_FUNCTION_ROLE_ARN" {
  value = aws_iam_role.confirm_forgot_password_function_role.arn
}
output "CONFIRM_FORGOT_PASSWORD_FUNCTION_ROLE_NAME" {
  value = aws_iam_role.confirm_forgot_password_function_role.name
}

# =================================================================
#  CONFIRM_SIGNUP  ROLE
# =================================================================
output "CONFIRM_SIGNUP_FUNCTION_ROLE_ARN" {
  value = aws_iam_role.confirm_signup_function_role.arn
}
output "CONFIRM_SIGNUP_FUNCTION_ROLE_NAME" {
  value = aws_iam_role.confirm_signup_function_role.name
}
