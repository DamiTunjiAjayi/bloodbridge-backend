# =================================================================
#  SIGNUP ROLE
# =================================================================
resource "aws_iam_role" "sign_up_function_role" {
  name = "${var.RESOURCES_PREFIX}_SIGN_UP_FUNCTION"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# =================================================================
#  RESEND_CODE ROLE
# =================================================================
resource "aws_iam_role" "resend_code_function_role" {
  name = "${var.RESOURCES_PREFIX}_RESEND_CODE_FUNCTION"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# =================================================================
#  CHANGE_PASSWORD
# =================================================================
resource "aws_iam_role" "change_password_function_role" {
  name = "${var.RESOURCES_PREFIX}_CHANGE_PASSWORD_FUNCTION"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# =================================================================
#  VERIFY_ACCOUNT
# =================================================================
resource "aws_iam_role" "verify_account_function_role" {
  name = "${var.RESOURCES_PREFIX}_VERIFY_ACCOUNT_FUNCTION"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# =================================================================
#  LOGIN
# =================================================================
resource "aws_iam_role" "login_function_role" {
  name = "${var.RESOURCES_PREFIX}_LOGIN_FUNCTION"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# =================================================================
#  FORGOT_PASSWORD
# =================================================================
resource "aws_iam_role" "forgot_password_function_role" {
  name = "${var.RESOURCES_PREFIX}_FORGOT_PASSWORD_FUNCTION"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# =================================================================
#  CONFIRM_FORGOT_PASSWORD
# =================================================================
resource "aws_iam_role" "confirm_forgot_password_function_role" {
  name = "${var.RESOURCES_PREFIX}_CONFIRM_FORGOT_PASSWORD_FUNCTION"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# =================================================================
#  CONFIRM_SIGNUP
# =================================================================
resource "aws_iam_role" "confirm_signup_function_role" {
  name = "${var.RESOURCES_PREFIX}_CONFIRM_SIGNUP_FUNCTION"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
