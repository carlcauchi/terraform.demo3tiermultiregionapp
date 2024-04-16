# Export the LB DNS Name
output "app-us-east-1-lb_dns_name" {
  value = module.app-us-east-1.lb_dns_name
}

# Export the LB DNS Name
output "app-eu-central-1-lb_dns_name" {
  value = module.app-eu-central-1.lb_dns_name
}