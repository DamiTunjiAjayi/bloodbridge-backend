locals {
  LAMBDA_VERSION = "v1"
}

################################################################################
# Layer
################################################################################
resource "aws_lambda_layer_version" "lambda_utils_layer" {
  filename                 = "${path.module}/layers/utils.zip"
  layer_name               = "${var.RESOURCES_PREFIX}-utils"
  source_code_hash         = data.archive_file.lambda_utils_layer_archive.output_base64sha256
  compatible_runtimes      = [var.LAMBDA_PYTHON_VERSION]
  compatible_architectures = ["x86_64", "arm64"]
}

resource "aws_lambda_layer_version" "javascript_layer" {
  filename                 = "${path.module}/layers/javascript_layer.zip"
  layer_name               = "${var.RESOURCES_PREFIX}-javascript-layer"
  compatible_runtimes      = [var.LAMBDA_JAVASCRIPT_VERSION]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "javascript layer for node lambdas"
}

resource "aws_lambda_layer_version" "python_layer" {
  filename                 = "${path.module}/layers/python_layer.zip"
  layer_name               = "${var.RESOURCES_PREFIX}-python-layer"
  compatible_runtimes      = [var.LAMBDA_PYTHON_VERSION]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "Python layer for python lambdas"
}

resource "aws_lambda_layer_version" "default_layer" {
  filename                 = "${path.module}/layers/default_layer.zip"
  layer_name               = "${var.RESOURCES_PREFIX}-default-layer"
  compatible_runtimes      = [var.LAMBDA_PYTHON_VERSION]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "Default layer for python lambdas"
}

# resource "aws_lambda_layer_version" "request_layer" {
#   filename   = "${path.module}/layers/request.zip"
#   layer_name = "${var.RESOURCES_PREFIX}-requests-layer"
#   compatible_runtimes      = [var.LAMBDA_PYTHON_VERSION]
#   compatible_architectures = ["x86_64", "arm64"]
#   description              = "requests layer"
# }

# =================================================================
# Create a Lambda function for signup
# =========================================================================
resource "aws_lambda_function" "sign_up_function" {
  filename         = "${path.module}/codes/zip/sign_up.zip"
  function_name    = "${var.RESOURCES_PREFIX}-sign_up-${local.LAMBDA_VERSION}"
  role             = var.SIGN_UP_FUNCTION_ROLE_ARN
  handler          = "sign_up.lambda_handler"
  source_code_hash = data.archive_file.lambda_sign_up_archive.output_base64sha256
  runtime          = var.LAMBDA_JAVASCRIPT_VERSION
  timeout          = 180
  memory_size      = 1024
  tags = var.tags
  environment {
    variables = {
      ENV                   = "${var.ENV}"
      INFO_EMAIL            = "${var.INFO_EMAIL}"
      CURRENT_AWS_REGION    = "${var.AWS_REGION}"
      USER_TABLE_NAME         = "${var.USER_TABLE_NAME}"
      MONGODB_URI                            = var.MONGODB_URI
    #   CLIENT_SECRET         = "${var.CLIENT_SECRET}"
    #   CLIENT_ID             = "${var.CLIENT_ID}"
    #   POOL_ID               = "${var.POOL_ID}"
    }
  }
  layers = ["${aws_lambda_layer_version.javascript_layer.arn}"]
}

# =================================================================
# Create a Lambda function for resend_code
# =========================================================================
resource "aws_lambda_function" "resend_code_function" {
  filename         = "${path.module}/codes/zip/resend_code.zip"
  function_name    = "${var.RESOURCES_PREFIX}-resend_code-${local.LAMBDA_VERSION}"
  role             = var.RESEND_CODE_FUNCTION_ROLE_ARN
  handler          = "resend_code.lambda_handler"
  source_code_hash = data.archive_file.lambda_resend_code_archive.output_base64sha256
  runtime          = var.LAMBDA_JAVASCRIPT_VERSION
  timeout          = 180
  memory_size      = 1024
  tags = var.tags
  environment {
    variables = {
      ENV                   = "${var.ENV}"
      INFO_EMAIL            = "${var.INFO_EMAIL}"
      CURRENT_AWS_REGION    = "${var.AWS_REGION}"
      USER_TABLE_NAME         = "${var.USER_TABLE_NAME}"
      MONGODB_URI                            = var.MONGODB_URI
      # CLIENT_SECRET         = "${var.CLIENT_SECRET}"
      # CLIENT_ID             = "${var.CLIENT_ID}"
      # POOL_ID               = "${var.POOL_ID}"
  }
  }
  layers = ["${aws_lambda_layer_version.javascript_layer.arn}"]
}

# =================================================================
# Create a Lambda function for change_password
# =========================================================================
resource "aws_lambda_function" "change_password_function" {
  filename         = "${path.module}/codes/zip/change_password.zip"
  function_name    = "${var.RESOURCES_PREFIX}-change_password-${local.LAMBDA_VERSION}"
  role             = var.CHANGE_PASSWORD_FUNCTION_ROLE_ARN
  handler          = "change_password.lambda_handler"
  source_code_hash = data.archive_file.lambda_change_password_archive.output_base64sha256
  runtime          = var.LAMBDA_JAVASCRIPT_VERSION
  timeout          = 180
  memory_size      = 1024
  tags = var.tags
  environment {
    variables = {
      ENV                   = "${var.ENV}"
      INFO_EMAIL            = "${var.INFO_EMAIL}"
      CURRENT_AWS_REGION    = "${var.AWS_REGION}"
      USER_TABLE_NAME         = "${var.USER_TABLE_NAME}"
      MONGODB_URI                            = var.MONGODB_URI
      # CLIENT_SECRET         = "${var.CLIENT_SECRET}"
      # CLIENT_ID             = "${var.CLIENT_ID}"
      # POOL_ID               = "${var.POOL_ID}"
  }
  }
  layers = ["${aws_lambda_layer_version.javascript_layer.arn}"]

}

# =================================================================
# Create a Lambda function for verify_account
# =========================================================================
resource "aws_lambda_function" "verify_account_function" {
  filename         = "${path.module}/codes/zip/verify_account.zip"
  function_name    = "${var.RESOURCES_PREFIX}-verify_account-${local.LAMBDA_VERSION}"
  role             = var.VERIFY_ACCOUNT_FUNCTION_ROLE_ARN
  handler          = "verify_account.lambda_handler"
  source_code_hash = data.archive_file.lambda_verify_account_archive.output_base64sha256
  runtime          = var.LAMBDA_JAVASCRIPT_VERSION
  timeout          = 180
  memory_size      = 1024
  tags = var.tags
  environment {
    variables = {
      ENV                   = "${var.ENV}"
      INFO_EMAIL            = "${var.INFO_EMAIL}"
      CURRENT_AWS_REGION    = "${var.AWS_REGION}"
      USER_TABLE_NAME         = "${var.USER_TABLE_NAME}"
      MONGODB_URI                            = var.MONGODB_URI
      # CLIENT_SECRET         = "${var.CLIENT_SECRET}"
      # CLIENT_ID             = "${var.CLIENT_ID}"
      # POOL_ID               = "${var.POOL_ID}"
  }
  }
  layers = ["${aws_lambda_layer_version.javascript_layer.arn}"]
}

# =================================================================
# Create a Lambda function for login
# =========================================================================
resource "aws_lambda_function" "login_function" {
  filename         = "${path.module}/codes/zip/login.zip"
  function_name    = "${var.RESOURCES_PREFIX}-login-${local.LAMBDA_VERSION}"
  role             = var.LOGIN_FUNCTION_ROLE_ARN
  handler          = "login.lambda_handler"
  source_code_hash = data.archive_file.lambda_login_archive.output_base64sha256
  runtime          = var.LAMBDA_JAVASCRIPT_VERSION
  timeout          = 180
  memory_size      = 1024
  tags = var.tags
  environment {
    variables = {
      ENV                   = "${var.ENV}"
      INFO_EMAIL            = "${var.INFO_EMAIL}"
      CURRENT_AWS_REGION    = "${var.AWS_REGION}"
      USER_TABLE_NAME         = "${var.USER_TABLE_NAME}"
      MONGODB_URI                            = var.MONGODB_URI
      # CLIENT_SECRET         = "${var.CLIENT_SECRET}"
      # CLIENT_ID             = "${var.CLIENT_ID}"
      # POOL_ID               = "${var.POOL_ID}"
  }
  }
  layers = ["${aws_lambda_layer_version.javascript_layer.arn}"]
}

# =================================================================
# Create a Lambda function for forgot password
# =========================================================================
resource "aws_lambda_function" "forgot_password_function" {
  filename         = "${path.module}/codes/zip/forgot_password.zip"
  function_name    = "${var.RESOURCES_PREFIX}-forgot_password-${local.LAMBDA_VERSION}"
  role             = var.FORGOT_PASSWORD_FUNCTION_ROLE_ARN
  handler          = "forgot_password.lambda_handler"
  source_code_hash = data.archive_file.lambda_forgot_password_archive.output_base64sha256
  runtime          = var.LAMBDA_JAVASCRIPT_VERSION
  timeout          = 180
  memory_size      = 1024
  tags = var.tags
  environment {
    variables = {
      ENV                   = "${var.ENV}"
      INFO_EMAIL            = "${var.INFO_EMAIL}"
      CURRENT_AWS_REGION    = "${var.AWS_REGION}"
      USER_TABLE_NAME         = "${var.USER_TABLE_NAME}"
      MONGODB_URI                            = var.MONGODB_URI
      # CLIENT_SECRET         = "${var.CLIENT_SECRET}"
      # CLIENT_ID             = "${var.CLIENT_ID}"
      # POOL_ID               = "${var.POOL_ID}"
  }
  }
  layers = ["${aws_lambda_layer_version.javascript_layer.arn}"]
}


# =================================================================
# Create a Lambda function for confirm forgot password
# =========================================================================
resource "aws_lambda_function" "confirm_forgot_password_function" {
  filename         = "${path.module}/codes/zip/confirm_forgot_password.zip"
  function_name    = "${var.RESOURCES_PREFIX}-confirm_forgot_password-${local.LAMBDA_VERSION}"
  role             = var.CONFIRM_FORGOT_PASSWORD_FUNCTION_ROLE_ARN
  handler          = "login.lambda_handler"
  source_code_hash = data.archive_file.lambda_confirm_forgot_password_archive.output_base64sha256
  runtime          = var.LAMBDA_JAVASCRIPT_VERSION
  timeout          = 180
  memory_size      = 1024
  tags = var.tags
  environment {
    variables = {
      ENV                   = "${var.ENV}"
      INFO_EMAIL            = "${var.INFO_EMAIL}"
      CURRENT_AWS_REGION    = "${var.AWS_REGION}"
      USER_TABLE_NAME         = "${var.USER_TABLE_NAME}"
      MONGODB_URI                            = var.MONGODB_URI
      # CLIENT_SECRET         = "${var.CLIENT_SECRET}"
      # CLIENT_ID             = "${var.CLIENT_ID}"
      # POOL_ID               = "${var.POOL_ID}"
  }
  }
  layers = ["${aws_lambda_layer_version.javascript_layer.arn}"]
}

# =================================================================
# Create a Lambda function for confirm signup
# =========================================================================
resource "aws_lambda_function" "confirm_signup_function" {
  filename         = "${path.module}/codes/zip/confirm_signup.zip"
  function_name    = "${var.RESOURCES_PREFIX}-confirm_signup-${local.LAMBDA_VERSION}"
  role             = var.CONFIRM_SIGNUP_FUNCTION_ROLE_ARN
  handler          = "confirm_signup.lambda_handler"
  source_code_hash = data.archive_file.lambda_confirm_signup_archive.output_base64sha256
  runtime          = var.LAMBDA_JAVASCRIPT_VERSION
  timeout          = 180
  memory_size      = 1024
  tags = var.tags
  environment {
    variables = {
      ENV                   = "${var.ENV}"
      INFO_EMAIL            = "${var.INFO_EMAIL}"
      CURRENT_AWS_REGION    = "${var.AWS_REGION}"
      USER_TABLE_NAME         = "${var.USER_TABLE_NAME}"
      MONGODB_URI                            = var.MONGODB_URI
      # CLIENT_SECRET         = "${var.CLIENT_SECRET}"
      # CLIENT_ID             = "${var.CLIENT_ID}"
      # POOL_ID               = "${var.POOL_ID}"
  }
  }
  layers = ["${aws_lambda_layer_version.javascript_layer.arn}"]
}
