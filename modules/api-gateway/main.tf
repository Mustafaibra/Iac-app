


resource "aws_api_gateway_rest_api" "dls-gateway" {
  name = var.api-name

}

resource "aws_api_gateway_resource" "dls-gateway-resource" {
  parent_id   = aws_api_gateway_rest_api.dls-gateway.root_resource_id
  path_part   = "devices"
  rest_api_id = aws_api_gateway_rest_api.dls-gateway.id
}

resource "aws_api_gateway_method" "dls-gateway-method" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.dls-gateway-resource.id
  rest_api_id   = aws_api_gateway_rest_api.dls-gateway.id
}


resource "aws_api_gateway_integration" "lb-integration" {
  rest_api_id = aws_api_gateway_rest_api.dls-gateway.id
  resource_id = aws_api_gateway_resource.dls-gateway-resource.id
  http_method = aws_api_gateway_method.dls-gateway-method.http_method

  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = var.lb-dns
  connection_type         = var.connection_type
  connection_id           = var.connection_id
}

resource "aws_api_gateway_deployment" "deployment" {

  depends_on = [aws_api_gateway_integration.lb-integration]


  rest_api_id = aws_api_gateway_rest_api.dls-gateway.id
  stage_name  = "prod"
}

resource "aws_api_gateway_stage" "stage-prod" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.dls-gateway.id
  stage_name    = "prod"
}

