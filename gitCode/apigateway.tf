resource "aws_api_gateway_rest_api" "api" {
  name = "CustomerEligibleAPI"
}

resource "aws_api_gateway_resource" "base_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "sub_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.base_resource.id
  path_part   = "cns"
}

resource "aws_api_gateway_resource" "int_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.sub_resource.id
  path_part   = "int"
}

resource "aws_api_gateway_resource" "sbl_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.int_resource.id
  path_part   = "SmallBusinessLending"
}

resource "aws_api_gateway_resource" "version_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.sbl_resource.id
  path_part   = "1.0"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.version_resource.id
  path_part   = "iscustomereligible"
}


resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
  request_validator_id = aws_api_gateway_request_validator.validator.id
   request_parameters = {
    "method.request.header.TraceId" = true
    "method.request.header.AppName" = true
    "method.request.querystring.tin" = true
  }
}

resource "aws_api_gateway_request_validator" "validator" {
  name         = "MyRequestValidator"
  rest_api_id  = aws_api_gateway_rest_api.api.id

  validate_request_parameters = true
}


resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"  # Enable Lambda proxy integration
  uri                     = aws_lambda_function.lambda.invoke_arn
  
}

resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_integration.request_method_integration.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}
  
