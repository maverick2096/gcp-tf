output "lb_ip" {
  description = "Static external IP — set as LB_IP in deploy-rancher.sh and create DNS A record here"
  value       = module.rancher_lb.lb_ip
}

output "backend_service_name" {
  description = "Backend service name"
  value       = module.rancher_lb.backend_service_name
}

output "instance_group_self_link" {
  description = "Instance group self-link"
  value       = module.rancher_lb.instance_group_self_link
}

output "forwarding_rule_ids" {
  description = "Forwarding rule IDs keyed by port name"
  value       = module.rancher_lb.forwarding_rule_ids
}

output "next_step" {
  description = "What to do after apply"
  value       = "1. DNS A record → ${module.rancher_lb.lb_ip}\n2. Set LB_IP=${module.rancher_lb.lb_ip} in deploy-rancher.sh\n3. Run deploy-rancher.sh"
}
