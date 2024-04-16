# Export the LB DNS Name
output "lb_dns_name" {
  value = aws_lb.demoapp_alb.dns_name
}