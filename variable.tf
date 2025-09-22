variable "region" {
  default = "us-east-1"
}

variable "ENV" {
  type    = string
  default = "dev"
}

variable "LAMBDA_PYTHON_VERSION" {
  type    = string
  default = "python3.13"
}

variable "LAMBDA_JAVASCRIPT_VERSION" {
  type    = string
  default = "nodejs18.x"
}

variable "IAM_COGNITO_ASSUMABLE_ROLE_EXTERNAL_ID" {
  default = "bloodbridge-external-12345"
  type    = string
}

variable "WEBAPP_DNS" {
  default = "http://bloodbridge.s3-website-us-east-1.amazonaws.com"
}

variable "COGNITO_GROUP_LIST" {
  type    = string
  default = "customer"
}

variable "RESEND_API_KEY" {
  default = "re_8UngmHQ4_HYEWNtF6cGnWwFzknuXQN3Cd"
}