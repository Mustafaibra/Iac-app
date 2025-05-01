

resource "aws_lb" "main-lb" {
  name               = "main-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sec_group.id] 
  subnets            = [aws_subnet.public-subnet-1.id,aws_subnet.public-subnet-2.id]

  enable_deletion_protection = false

  
  tags = {
    Environment = "prod-lambda-lb"
  }
}

resource "aws_lb_listener" "main-listener" {
  load_balancer_arn = aws_lb.main-lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda-target-group.arn
  }


}

resource "aws_lb_target_group" "lambda-target-group" {
  name     = "myLoadBalancerTargets"
  target_type = "lambda"
  vpc_id   = aws_vpc.mian-Vpc.id
}

resource "aws_lb_target_group_attachment" "target_group_attachment" {
  target_group_arn = aws_lb_target_group.lambda-target-group.arn
  target_id        = aws_lambda_function.main-lambda-function.arn
}

resource "aws_lambda_permission" "with_lb" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.main-lambda-function.arn}"
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.lambda-target-group.arn
}





#excution role 
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda-payload" {
  type        = "zip"
  source_file = "index.mjs"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "main-lambda-function" {
  filename      = "lambda_function_payload.zip"
  function_name = "saying-hello"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  ephemeral_storage {
    size = 512 # Min 512 MB and the Max 10240 MB
  }
}

// api gatway integration 

resource "aws_apigatewayv2_vpc_link" "vpclink-lb-gateway2" {
  name               = "vpclink lb gatway2"
  security_group_ids = []
  subnet_ids         = [aws_subnet.public-subnet-1.id,aws_subnet.public-subnet-2.id]
  


}
module "api-gatway2-module" {
  source = "./modules/api-gatway2"
  lb-listener-arn = aws_lb_listener.main-listener.arn
  vpclink-lb-gateway2 = aws_apigatewayv2_vpc_link.vpclink-lb-gateway2.id
}

resource "aws_iam_role" "api_gateway_role" {
  name = "api-gateway-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "api_gateway_policy" {
  name        = "api-gateway-policy"
  description = "IAM policy for API Gateway to interact with ALB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_attachment" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_gateway_policy.arn
}

/*resource "aws_api_gateway_vpc_link" "gateway-vpc-link" {
  name        = "my-vpc-link"
  target_arns = [aws_lb.main-lb.arn]
}


module "api_gateway_module" {
  source           = "./modules/api-gateway"
  lb-dns =  aws_lb.main-lb.dns_name
  api-name         = "dls-gateway"
  connection_id = aws_api_gateway_vpc_link.gateway-vpc-link.id
  connection_type = "VPC_LINK"
}


resource "aws_iam_role" "api_gateway_role" {
  name = "api-gateway-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "api_gateway_policy" {
  name   = "APIGatewayPolicy"
  

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "apigateway:CreateVpcLink",
          "apigateway:DeleteVpcLink",
          "apigateway:GetVpcLinks",
          "apigateway:UpdateVpcLink"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_attachment" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_gateway_policy.arn
}


resource "aws_iam_role" "api_gateway_vpc_link_role" {
  name = "api-gateway-vpc-link-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_policy" "api_gateway_vpc_link_policy" {
  name        = "api-gateway-vpc-link-policy"
  description = "IAM policy for API Gateway VPC Link to access ALB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "api_gateway_vpc_link_policy_attachment" {
  role       = aws_iam_role.api_gateway_vpc_link_role.name
  policy_arn = aws_iam_policy.api_gateway_vpc_link_policy.arn
}*/

