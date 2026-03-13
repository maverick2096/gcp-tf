output "instance_names" {
  description = "Names of the created compute instances."
  value       = module.compute_instance.instances_details[*].name
}

output "instance_self_links" {
  description = "Self-links of the created compute instances."
  value       = module.compute_instance.instances_details[*].self_link
}

output "internal_ips" {
  description = "Internal IP addresses of the instances."
  value       = module.compute_instance.instances_details[*].network_interface[0].network_ip
}

output "instance_template_self_link" {
  description = "Self-link of the instance template used."
  value       = module.instance_template.self_link
}

output "data_disk_names" {
  description = "Names assigned to each additional data disk (in declaration order)."
  value       = [for d in local.additional_disks_normalised : d.disk_name]
}

output "data_disk_count" {
  description = "Number of additional data disks attached per instance."
  value       = length(var.additional_disks)
}
