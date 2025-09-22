resource "random_id" "s3_suffix" {
  byte_length = 4
}

locals {
  RESOURCES_PREFIX = "${lower(var.ENV)}-bloodbridge"
  ACCOUNTID        = data.aws_caller_identity.current.account_id
  INFO_EMAIL       = "bloodbridgenaija@gmail.com"



  common_tags = {
    environment = var.ENV
    project     = "bloodbridge"
  }
}

module "role" {
  source           = "./module/role"
  ENV              = var.ENV
  AWS_REGION       = var.region
  RESOURCES_PREFIX = local.RESOURCES_PREFIX

}

# POlicy
module "policy" {
  source                                     = "./module/policy"
  ENV                                        = var.ENV
  AWS_REGION                                 = var.region
  RESOURCES_PREFIX                           = local.RESOURCES_PREFIX
  CURRENT_ACCOUNT_ID                         = data.aws_caller_identity.current.account_id
  INFO_EMAIL                                 = local.INFO_EMAIL
  SIGN_UP_FUNCTION_ROLE_NAME                 = module.role.SIGN_UP_FUNCTION_ROLE_NAME
  RESEND_CODE_FUNCTION_ROLE_NAME             = module.role.RESEND_CODE_FUNCTION_ROLE_NAME
  LOGIN_FUNCTION_ROLE_NAME                   = module.role.LOGIN_FUNCTION_ROLE_NAME
  VERIFY_ACCOUNT_FUNCTION_ROLE_NAME          = module.role.VERIFY_ACCOUNT_FUNCTION_ROLE_NAME
  CHANGE_PASSWORD_FUNCTION_ROLE_NAME         = module.role.CHANGE_PASSWORD_FUNCTION_ROLE_NAME
  FORGOT_PASSWORD_FUNCTION_ROLE_NAME         = module.role.FORGOT_PASSWORD_FUNCTION_ROLE_NAME
  CONFIRM_FORGOT_PASSWORD_FUNCTION_ROLE_NAME = module.role.CONFIRM_FORGOT_PASSWORD_FUNCTION_ROLE_NAME
  CONFIRM_SIGNUP_FUNCTION_ROLE_NAME          = module.role.CONFIRM_SIGNUP_FUNCTION_ROLE_NAME

}


# Lambda
module "lambda" {
  source           = "./module/lambda"
  ENV              = var.ENV
  AWS_REGION       = var.region
  tags             = local.common_tags
  RESOURCES_PREFIX = local.RESOURCES_PREFIX
  INFO_EMAIL       = local.INFO_EMAIL
  # LAMBDA_JAVASCRIPT_VERSION               = var.LAMBDA_JAVASCRIPT_VERSION
  LAMBDA_PYTHON_VERSION   = var.LAMBDA_PYTHON_VERSION
  USER_TABLE_NAME         = module.user_table_dynamodb.table_name
  # CLIENT_SECRET = module.cognito_end_user.COGNITO_USER_CLIENT_SECRET
  # CLIENT_ID     = module.cognito_end_user.COGNITO_USER_CLIENT_ID
  # POOL_ID       = module.cognito_end_user.COGNITO_USER_POOL_ID

  SIGN_UP_FUNCTION_ROLE_ARN                 = module.role.SIGN_UP_FUNCTION_ROLE_ARN
  RESEND_CODE_FUNCTION_ROLE_ARN             = module.role.RESEND_CODE_FUNCTION_ROLE_ARN
  LOGIN_FUNCTION_ROLE_ARN                   = module.role.LOGIN_FUNCTION_ROLE_ARN
  VERIFY_ACCOUNT_FUNCTION_ROLE_ARN          = module.role.VERIFY_ACCOUNT_FUNCTION_ROLE_ARN
  CHANGE_PASSWORD_FUNCTION_ROLE_ARN         = module.role.CHANGE_PASSWORD_FUNCTION_ROLE_ARN
  FORGOT_PASSWORD_FUNCTION_ROLE_ARN         = module.role.FORGOT_PASSWORD_FUNCTION_ROLE_ARN
  CONFIRM_FORGOT_PASSWORD_FUNCTION_ROLE_ARN = module.role.CONFIRM_FORGOT_PASSWORD_FUNCTION_ROLE_ARN
  CONFIRM_SIGNUP_FUNCTION_ROLE_ARN          = module.role.CONFIRM_SIGNUP_FUNCTION_ROLE_ARN
  
}


# DYNAMODB TABLE
module "user_table_dynamodb" {
  source           = "./module/dynamodb/user_table"
  ENV              = var.ENV
  AWS_REGION       = var.region
  RESOURCES_PREFIX = local.RESOURCES_PREFIX
  table_name       = "user_table"
}








#api module

module "api" {
  source             = "./module/api"
  ENV                = var.ENV
  RESOURCES_PREFIX   = local.RESOURCES_PREFIX
  CURRENT_ACCOUNT_ID = data.aws_caller_identity.current.account_id
  depends_on         = [module.lambda]
  # API_DOMAIN_NAME                                   = local.DOMAIN_NAME
  LAMBDA_SIGN_UP_FUNCTION_ARN                 = module.lambda.LAMBDA_SIGN_UP_FUNCTION_ARN
  LAMBDA_RESEND_CODE_FUNCTION_ARN             = module.lambda.LAMBDA_RESEND_CODE_FUNCTION_ARN
  LAMBDA_LOGIN_FUNCTION_ARN                   = module.lambda.LAMBDA_LOGIN_FUNCTION_ARN
  LAMBDA_VERIFY_ACCOUNT_FUNCTION_ARN          = module.lambda.LAMBDA_VERIFY_ACCOUNT_FUNCTION_ARN
  LAMBDA_CHANGE_PASSWORD_FUNCTION_ARN         = module.lambda.LAMBDA_CHANGE_PASSWORD_FUNCTION_ARN
  LAMBDA_FORGOT_PASSWORD_FUNCTION_ARN         = module.lambda.LAMBDA_FORGOT_PASSWORD_FUNCTION_ARN
  LAMBDA_CONFIRM_FORGOT_PASSWORD_FUNCTION_ARN = module.lambda.LAMBDA_CONFIRM_FORGOT_PASSWORD_FUNCTION_ARN
  LAMBDA_CONFIRM_SIGNUP_FUNCTION_ARN          = module.lambda.LAMBDA_CONFIRM_SIGNUP_FUNCTION_ARN
 

  LAMBDA_NAMES = [
    module.lambda.LAMBDA_SIGN_UP_FUNCTION_NAME,
    module.lambda.LAMBDA_RESEND_CODE_FUNCTION_NAME,
    module.lambda.LAMBDA_LOGIN_FUNCTION_NAME,
    module.lambda.LAMBDA_CHANGE_PASSWORD_FUNCTION_NAME,
    module.lambda.LAMBDA_VERIFY_ACCOUNT_FUNCTION_NAME,
    module.lambda.LAMBDA_FORGOT_PASSWORD_FUNCTION_NAME,
    module.lambda.LAMBDA_CONFIRM_FORGOT_PASSWORD_FUNCTION_NAME,
    module.lambda.LAMBDA_CONFIRM_SIGNUP_FUNCTION_NAME,
    


  ]

}


# ##==================================================
# #  SES creation..
# ##==================================================
# module "ses" {
#   source     = "./module/ses"
#   INFO_EMAIL = local.INFO_EMAIL
#   tags       = local.common_tags

# }

# module "s3" {
#   source           = "./module/s3"
#   RESOURCES_PREFIX = local.RESOURCES_PREFIX
#   BUCKET_NAME      = "${local.RESOURCES_PREFIX}-email-templates"
#   tags             = local.common_tags

# }

##==================================================
#  cognito creation..
##==================================================

module "cognito_end_user" {
  source      = "./module/cognito"
  ENV         = var.ENV
  COMMON_TAGS = local.common_tags
  # EMAIL_SENDER                           = local.INFO_EMAIL
  IAM_COGNITO_ASSUMABLE_ROLE_EXTERNAL_ID = var.IAM_COGNITO_ASSUMABLE_ROLE_EXTERNAL_ID
  AWS_REGION                             = data.aws_region.current.name
  # CURRENT_ACCOUNT_ID                     = local.ACCOUNTID
  WEBAPP_DNS            = var.WEBAPP_DNS
  COGNITO_GROUP_LIST    = var.COGNITO_GROUP_LIST
  RESOURCE_PREFIX       = local.RESOURCES_PREFIX
  BUCKET_NAME           = module.s3.MESSAGING_BUCKET_NAME
  PYTHON_LAMBDA_VERSION = var.LAMBDA_PYTHON_VERSION
  # COGNITO_DOMAIN_NAME                    = local.cognito_domain_name
  RESEND_API_KEY  = var.RESEND_API_KEY
  USER_TABLE_NAME = module.user_table_dynamodb.table_name
}


