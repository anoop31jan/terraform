variable "request_parameters" {
  type    = map(bool)
  default = {
    "method.request.header.TraceId" = true
    "method.request.header.AppName" = true
    "method.request.querystring.tin" = true
  }
}



resource "aws_api_gateway_request_validator" "validator" {
  name        = "MyRequestValidator"
  rest_api_id = var.rest_api_id
  validate_request_parameters = true
}

resource "aws_api_gateway_method" "method" {
  rest_api_id            = var.rest_api_id
  resource_id            = var.resource_id
  http_method            = "GET"
  authorization          = "NONE"
  request_validator_id   = aws_api_gateway_request_validator.validator.id
  request_parameters     = var.request_parameters
}

# Other resources like aws_api_gateway_resource, aws_api_gateway_rest_api, etc.



module "my_api_gateway" {
  source            = "./api_gateway"  # Replace with the actual source path
  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.resource.id
  request_parameters = {
    "method.request.header.TraceId" = true
    "method.request.header.AppName" = true
    "method.request.querystring.tin" = true
    # You can customize the parameters here
  }
}

# You can use the output of the module if needed
output "method_id" {
  value = module.my_api_gateway.method_id
}



