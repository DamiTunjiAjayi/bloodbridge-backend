#creates the userpool
resource "aws_cognito_user_pool" "congito_end_user_userpool" {
  name                       = "${var.RESOURCE_PREFIX}-userpool"
  alias_attributes           = ["preferred_username"]
  auto_verified_attributes   = ["email"]
  mfa_configuration          = "OPTIONAL"
  sms_authentication_message = "${var.RESOURCE_PREFIX} verification code is {####}"

  password_policy {
    minimum_length                   = 8
    temporary_password_validity_days = 1
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    require_lowercase                = true
  }

  user_pool_add_ons {
    advanced_security_mode = "OFF"
  }


  verification_message_template {
    default_email_option  = "CONFIRM_WITH_CODE"
    email_message         = "Hello {email}, Welcome, your journey starts here! Your Verification Code is: {####} If you need any assistance please contact us at safespace196@gmail.com. We are here to assist. Regards, Safespace Team"
    email_message_by_link = "Hello,<br/><br/>You organisation account owner has created a ${var.RESOURCE_PREFIX} account for you on the <b>OAF</b> platform.<br/><br/>Please click the link below to verify your email address on the platform. {##Verify Email##}<br/><br/> You will receive a separate email address with your login details<br/><br/>Welcome to giggle learn<br/><br/>"
    email_subject         = "[Safespace] Registration Email Verification"
    email_subject_by_link = "Welcome to Bloodbridge"
    sms_message           = "Your Bloodbridge ${var.RESOURCE_PREFIX} reset password code is {####}"
  }

  username_configuration {
    case_sensitive = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = false

    invite_message_template {
      email_message = "Hello, <span>{username}</span></p><p class='p-paragraph'>To verify your account, please use the following One Time Password (OTP):{####}"
      email_subject = "Your temporary password"
      sms_message   = "Your email is {username} and temporary password is {####}"
    }
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  # lambda_config {
  #   # custom_message                 = aws_lambda_function.custom_message.arn
  #   create_auth_challenge          = aws_lambda_function.create_custom_auth.arn
  #   define_auth_challenge          = aws_lambda_function.define_custom_auth.arn
  #   verify_auth_challenge_response = aws_lambda_function.verify_custom_auth.arn
  # }
  sms_configuration {
    external_id    = var.IAM_COGNITO_ASSUMABLE_ROLE_EXTERNAL_ID
    sns_caller_arn = aws_iam_role.cognito_sms_role.arn
  }

  # email_configuration {
  #   email_sending_account = "DEVELOPER"
  #   # source_arn            = "arn:aws:ses:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:identity/${var.EMAIL_SENDER}"
  # }


  # schema {
  #   name                     = "customerID"
  #   attribute_data_type      = "String"
  #   developer_only_attribute = false
  #   mutable                  = true  # false for "sub"
  #   required                 = false # true for "sub"
  #   string_attribute_constraints {   
  #     min_length = 0                 
  #     max_length = 2048              
  #   }
  # }
  schema {
    name                     = "org_name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true  # false for "sub"
    required                 = false # true for "sub"
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "first_name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true  # false for "sub"
    required                 = false # true for "sub"
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                     = "last_name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true  # false for "sub"
    required                 = false # true for "sub"
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true  # false for "sub"
    required                 = false # true for "sub"
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                     = "mfa_type"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true  # false for "sub"
    required                 = false # true for "sub"
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                     = "mfa_setup"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true  # false for "sub"
    required                 = false # true for "sub"
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
      name                     = "user-type" # to know if a user is an individual or an organisation
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true  # false for "sub"
      required                 = false # true for "sub"
      string_attribute_constraints {
        min_length = 0
        max_length = 2048
      }
    }

  schema {
    name                     = "completed_setup"
    attribute_data_type      = "Boolean"
    developer_only_attribute = false
    mutable                  = true  # false for "sub"
    required                 = false # true for "sub"
  }

  tags = var.COMMON_TAGS
}

# creates user pool domain link 
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.RESOURCE_PREFIX}-112233"
  user_pool_id = aws_cognito_user_pool.congito_end_user_userpool.id
}

# creates the app client
resource "aws_cognito_user_pool_client" "cognito_client_end_user" {
  name                                 = "${var.RESOURCE_PREFIX}-app-client-end-user"
  user_pool_id                         = aws_cognito_user_pool.congito_end_user_userpool.id
  generate_secret                      = true
  allowed_oauth_flows                  = ["implicit"]
  explicit_auth_flows                  = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  callback_urls                        = ["https://${var.WEBAPP_DNS}"]
  supported_identity_providers         = ["COGNITO"]
  access_token_validity                = 1440
  refresh_token_validity               = 365


  read_attributes = [
    "email",
    "custom:completed_setup",          # 👈  custom attribute to include in the token
    "custom:user-type"  
  ]
  token_validity_units {
    refresh_token = "days"
    access_token  = "minutes"
  }

  depends_on = [
    aws_cognito_user_pool.congito_end_user_userpool
  ]
}
################################################################################################################
# iam role
################################################################################################################

resource "aws_iam_policy" "sms_policy" {
  name   = "${var.RESOURCE_PREFIX}-sms_policy-core"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "sns:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "cognito_sms_role" {
  name               = "${var.RESOURCE_PREFIX}-sms-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["cognito-idp.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags               = var.COMMON_TAGS
}
resource "aws_iam_role_policy_attachment" "policy_role_attachment" {
  role       = aws_iam_role.cognito_sms_role.id
  policy_arn = aws_iam_policy.sms_policy.arn
}

resource "aws_iam_role" "group_role" {
  name = "${var.RESOURCE_PREFIX}-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "us-east-1:12345678-dead-beef-cafe-123456790ab"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}



resource "aws_cognito_user_group" "cognito-user-groups" {
  description  = "user group managed by cloud@gigglelearn.com with terraform"
  name         = var.COGNITO_GROUP_LIST
  user_pool_id = aws_cognito_user_pool.congito_end_user_userpool.id
}


resource "aws_iam_role" "lambda_iam" {
  name = "${var.RESOURCE_PREFIX}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = var.COMMON_TAGS
}


resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "${var.RESOURCE_PREFIX}-lambda-policy"
  role = aws_iam_role.lambda_iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "customSignUpMessage" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.custom_message.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.congito_end_user_userpool.arn
  depends_on    = [aws_lambda_function.custom_message]


}

#---------------------------------------------------------------
# LAYERS
#---------------------------------------------------------------
resource "aws_lambda_layer_version" "request_layer" {
  filename                 = "${path.module}/request.zip"
  layer_name               = "${var.RESOURCE_PREFIX}-requests-layer"
  compatible_runtimes      = [var.PYTHON_LAMBDA_VERSION]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "requests layer"
}

resource "aws_lambda_function" "custom_message" {
  filename      = "${path.module}/code/zip/customSignUpMessage.zip"
  function_name = "${var.RESOURCE_PREFIX}_custom_message_lambda_function"
  role          = aws_iam_role.lambda_iam.arn
  handler       = "customSignUpMessage.lambda_handler"
  runtime       = var.PYTHON_LAMBDA_VERSION
  timeout       = 60

  environment {
    variables = {
      ENV            = "${var.ENV}"
      BUCKET_NAME    = "${var.BUCKET_NAME}"
      RESEND_API_KEY = var.RESEND_API_KEY
    }
  }
  layers = ["${aws_lambda_layer_version.request_layer.arn}"]
}


data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.module}/code/custom-auth/customSignUpMessage.py"
  output_path = "${path.module}/code/zip/customSignUpMessage.zip"
}

######### DEFINE CUSTOM AUTH LAMBDA  #############################

resource "aws_iam_role" "define_custom_auth_lambda_iam" {
  name = "${var.RESOURCE_PREFIX}-define-cusutom-auth-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = var.COMMON_TAGS
}

resource "aws_iam_role_policy" "lambda_define_custom_auth_role_policy" {
  name = "${var.RESOURCE_PREFIX}-define-cusutom-auth-lambda-policy"
  role = aws_iam_role.define_custom_auth_lambda_iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "defineCustomAuth" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.define_custom_auth.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.congito_end_user_userpool.arn
  depends_on    = [aws_lambda_function.define_custom_auth]


}

resource "aws_lambda_function" "define_custom_auth" {
  filename      = "${path.module}/code/zip/defineAuthChallenge.zip"
  function_name = "${var.RESOURCE_PREFIX}_define_custom_auth_lambda_function"
  role          = aws_iam_role.lambda_iam.arn
  handler       = "defineAuthChallenge.lambda_handler"
  runtime       = var.PYTHON_LAMBDA_VERSION
  memory_size   = 3008
  timeout       = 600
  publish       = true

  environment {
    variables = {
      ENV             = "${var.ENV}"
      USER_TABLE_NAME = "${var.USER_TABLE_NAME}"
    }
  }
}

data "archive_file" "define_auth_challenge_lambda_function" {
  type        = "zip"
  source_file = "${path.module}/code/custom-auth/defineAuthChallenge.py"
  output_path = "${path.module}/code/zip/defineAuthChallenge.zip"
}


######### CREATE CUSTOM AUTH LAMBDA  #############################
resource "aws_iam_role" "create_custom_auth_lambda_iam" {
  name = "${var.RESOURCE_PREFIX}-create-cusutom-auth-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = var.COMMON_TAGS
}

resource "aws_iam_role_policy" "lambda_create_custom_auth_role_policy" {
  name = "${var.RESOURCE_PREFIX}-create-cusutom-auth-lambda-policy"
  role = aws_iam_role.create_custom_auth_lambda_iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "createCustomAuth" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_custom_auth.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.congito_end_user_userpool.arn
  depends_on    = [aws_lambda_function.create_custom_auth]


}

resource "aws_lambda_function" "create_custom_auth" {
  filename      = "${path.module}/code/zip/createAuthChallenge.zip"
  function_name = "${var.RESOURCE_PREFIX}_create_custom_auth_lambda_function"
  role          = aws_iam_role.lambda_iam.arn
  handler       = "createAuthChallenge.lambda_handler"
  runtime       = var.PYTHON_LAMBDA_VERSION
  memory_size   = 3008
  timeout       = 600
  publish       = true

  environment {
    variables = {
      ENV             = "${var.ENV}"
      USER_TABLE_NAME = "${var.USER_TABLE_NAME}"
    }
  }
}

data "archive_file" "create_auth_challenge_lambda_function" {
  type        = "zip"
  source_file = "${path.module}/code/custom-auth/createAuthChallenge.py"
  output_path = "${path.module}/code/zip/createAuthChallenge.zip"
}

######### VERIFY CUSTOM AUTH LAMBDA  #############################
resource "aws_iam_role" "verify_custom_auth_lambda_iam" {
  name = "${var.RESOURCE_PREFIX}-verify-cusutom-auth-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = var.COMMON_TAGS
}

resource "aws_iam_role_policy" "lambda_verify_custom_auth_role_policy" {
  name = "${var.RESOURCE_PREFIX}-verify-cusutom-auth-lambda-policy"
  role = aws_iam_role.verify_custom_auth_lambda_iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "verifyCustomAuth" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.verify_custom_auth.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.congito_end_user_userpool.arn
  depends_on    = [aws_lambda_function.verify_custom_auth]


}

resource "aws_lambda_function" "verify_custom_auth" {
  filename      = "${path.module}/code/zip/verifyAuthChallenge.zip"
  function_name = "${var.RESOURCE_PREFIX}_verify_custom_auth_lambda_function"
  role          = aws_iam_role.lambda_iam.arn
  handler       = "verifyAuthChallenge.lambda_handler"
  runtime       = var.PYTHON_LAMBDA_VERSION
  memory_size   = 3008
  timeout       = 60
  publish       = true

  environment {
    variables = {
      ENV             = "${var.ENV}"
      USER_TABLE_NAME = "${var.USER_TABLE_NAME}"

    }
  }
}

data "archive_file" "verify_auth_challenge_lambda_function" {
  type        = "zip"
  source_file = "${path.module}/code/custom-auth/verifyAuthChallenge.py"
  output_path = "${path.module}/code/zip/verifyAuthChallenge.zip"
}
