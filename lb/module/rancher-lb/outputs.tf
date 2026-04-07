output "lb_ip" {
  description = "Static external IP of the load balancer. Set as LB_IP in deploy-rancher.sh and point your DNS A record here."
  value       = google_compute_address.lb.address
}

output "lb_address_name" {
  description = "GCP address resource name"
  value       = google_compute_address.lb.name
}

output "backend_service_id" {
  description = "Backend service self-link"
  value       = google_compute_region_backend_service.lb.id
}

output "backend_service_name" {
  description = "Backend service name"
  value       = google_compute_region_backend_service.lb.name
}

output "instance_group_self_link" {
  description = "Instance group self-link"
  value       = google_compute_instance_group.lb.self_link
}

output "health_check_id" {
  description = "Health check self-link"
  value       = google_compute_region_health_check.lb.id
}

output "forwarding_rule_ids" {
  description = "Map of forwarding rule self-links keyed by port name"
  value = {
    http    = google_compute_forwarding_rule.http.id
    https   = google_compute_forwarding_rule.https.id
    k8s_api = google_compute_forwarding_rule.k8s_api.id
  }
}
