
output "load_balancer_dns_name" {
  value = aws_lb.main-lb.dns_name
}

output "invoking-url-gateway2" {
  value = module.api-gatway2-module.invoking
}