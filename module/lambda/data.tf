data "archive_file" "lambda_utils_layer_archive" {
  type        = "zip"
  source_dir  = "${path.module}/layers/utils"
  output_path = "${path.module}/layers/utils.zip"
}

data "archive_file" "lambda_sign_up_archive" {
  type        = "zip"
  source_dir  = "${path.module}/codes/sign_up"
  output_path = "${path.module}/codes/zip/sign_up.zip"
}

data "archive_file" "lambda_resend_code_archive" {
  type        = "zip"
  source_dir  = "${path.module}/codes/resend_code"
  output_path = "${path.module}/codes/zip/resend_code.zip"
}

data "archive_file" "lambda_verify_account_archive" {
  type        = "zip"
  source_dir  = "${path.module}/codes/verify_account"
  output_path = "${path.module}/codes/zip/verify_account.zip"
}

data "archive_file" "lambda_change_password_archive" {
  type        = "zip"
  source_dir  = "${path.module}/codes/change_password"
  output_path = "${path.module}/codes/zip/change_password.zip"
}

data "archive_file" "lambda_login_archive" {
  type        = "zip"
  source_dir  = "${path.module}/codes/login"
  output_path = "${path.module}/codes/zip/login.zip"
}

data "archive_file" "lambda_forgot_password_archive" {
  type        = "zip"
  source_dir  = "${path.module}/codes/forgot_password"
  output_path = "${path.module}/codes/zip/forgot_password.zip"
}

data "archive_file" "lambda_confirm_forgot_password_archive" {
  type        = "zip"
  source_dir  = "${path.module}/codes/confirm_forgot_password"
  output_path = "${path.module}/codes/zip/confirm_forgot_password.zip"
}

data "archive_file" "lambda_confirm_signup_archive" {
  type        = "zip"
  source_dir  = "${path.module}/codes/confirm_signup"
  output_path = "${path.module}/codes/zip/confirm_signup.zip"
}