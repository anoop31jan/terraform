resource "aws_lambda_function" "lambda" {
 filename      = "C:\\Users\\Administrator\\IdeaProjects\\customereligible\\target\\customereligible-1.0-SNAPSHOT.jar"  # Replace with your Lambda deployment package
  function_name = "cma_custome_eligible_function"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "com.comerica.lambda.CustomerEligblityHandler::handleRequest"  # Replace with the correct handler function name in your Lambda
  runtime       = "java11"    # Change the runtime accordingly if you're using a different language
  timeout = 120
  environment {
    variables = {
      PartyDataMgmt = "your-value1",
      RELOAD        = "your-value2",
      SDB           = "your-value3"
    }
  }
}



resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# # Lambda
resource "aws_lambda_permission" "apigw_lambda" {
   statement_id  = "AllowExecutionFromAPIGateway"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.lambda.function_name
   principal     = "apigateway.amazonaws.com"

   # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
   source_arn = "arn:aws:execute-api:${var.myregion}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
 }




resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/cma_custome_eligible_function"  # Replace with your Lambda function name
  retention_in_days = 1  # Optional: Set retention period for the logs (in days)
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [aws_cloudwatch_log_group.lambda_logs.arn]
  }

}

resource "aws_iam_role_policy_attachment" "lambda_logs_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name

  depends_on = [aws_lambda_function.lambda, aws_cloudwatch_log_group.lambda_logs]
}
