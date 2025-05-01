

resource "aws_apigatewayv2_api" "dls-gatway2" {
  name          = "dls-http-api"
  protocol_type = "HTTP"
}


resource "aws_apigatewayv2_integration" "dls-gatway-lb-integration" {
  api_id           = aws_apigatewayv2_api.dls-gatway2.id
  
  description      = "Example with a load balancer"
  integration_type = "HTTP_PROXY"
  integration_uri  = var.lb-listener-arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = var.vpclink-lb-gateway2

  
}
resource "aws_apigatewayv2_route" "devices-routing" {
  api_id    = aws_apigatewayv2_api.dls-gatway2.id
  route_key = "GET /devices"

  target = "integrations/${aws_apigatewayv2_integration.dls-gatway-lb-integration.id}"
}

resource "aws_apigatewayv2_stage" "prod-stage" {
  api_id = aws_apigatewayv2_api.dls-gatway2.id
  name   = "prod-stage"
  auto_deploy = true
}