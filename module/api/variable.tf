variable "CURRENT_ACCOUNT_ID" {}
variable "ENV" {}
variable "BASE_PATH" {
  default = "api"
}

variable "LAMBDA_NAMES" {
  description = "contains Names of lambda(s) to be added into <aws_lambda_permission> resource"
  type        = list(string)
}
variable "RESOURCES_PREFIX" {}
variable "LAMBDA_SIGN_UP_FUNCTION_ARN" {}
variable "LAMBDA_RESEND_CODE_FUNCTION_ARN" {}
variable "LAMBDA_CHANGE_PASSWORD_FUNCTION_ARN" {}
variable "LAMBDA_VERIFY_ACCOUNT_FUNCTION_ARN" {}
variable "LAMBDA_LOGIN_FUNCTION_ARN" {}
variable "LAMBDA_FORGOT_PASSWORD_FUNCTION_ARN" {}
variable "LAMBDA_CONFIRM_FORGOT_PASSWORD_FUNCTION_ARN" {}
variable "LAMBDA_CONFIRM_SIGNUP_FUNCTION_ARN" {}
