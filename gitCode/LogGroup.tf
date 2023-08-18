variable "function_name" {
  description = "Name of the Lambda function"
}

variable "retention_days" {
  description = "Retention period for the logs (in days)"
  default     = 1
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = var.function_name
  retention_in_days = var.retention_days
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [aws_cloudwatch_log_group.lambda_logs.arn]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logs_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = var.lambda_role

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}


######################################################################################

variable "function_name" {
  description = "Name of the Lambda function"
}

variable "retention_days" {
  description = "Retention period for the logs (in days)"
  default     = 1
}

variable "lambda_role" {
  description = "IAM role for the Lambda function"
}

#################################################################

module "lambda_logs" {
  source       = "./log_group"
  function_name = "/aws/lambda/cma_custome_eligible_function"
  retention_days = 1
  lambda_role = aws_iam_role.lambda_exec.name
}

# Define your Lambda function resource and other configurations here


