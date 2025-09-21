variable "ENV" {}
variable "AWS_REGION" {}
variable "LAMBDA_PYTHON_VERSION" {}
# variable "LAMBDA_JAVASCRIPT_VERSION" {}
variable "RESOURCES_PREFIX" {}
variable "tags" {}
variable "INFO_EMAIL" {}
variable "USER_TABLE_NAME" {}
variable "CONVERSATION_TABLE_NAME" {}
variable "MESSAGES_TABLE_NAME" {}
variable "JOURNALS_TABLE_NAME" {}
variable "CONNECTION_TABLE_NAME" {}




variable "SIGN_UP_FUNCTION_ROLE_ARN" {}
variable "RESEND_CODE_FUNCTION_ROLE_ARN" {}
variable "VERIFY_ACCOUNT_FUNCTION_ROLE_ARN" {}
variable "CHANGE_PASSWORD_FUNCTION_ROLE_ARN" {}
variable "LOGIN_FUNCTION_ROLE_ARN" {}
variable "FORGOT_PASSWORD_FUNCTION_ROLE_ARN" {}
variable "CONFIRM_FORGOT_PASSWORD_FUNCTION_ROLE_ARN" {}
variable "CONFIRM_SIGNUP_FUNCTION_ROLE_ARN" {}
  







variable "CLIENT_SECRET" {
  # default = "lkihnjq316h801l9k4g2n4ddssruhhp2g02i5862rn7na27konj"
}
variable "CLIENT_ID" {
  # default = "3fruiekpk1uro5t8kvqi8t3gog"
}
variable "POOL_ID" {
  # default = "us-east-1_11cmR78v5"
}