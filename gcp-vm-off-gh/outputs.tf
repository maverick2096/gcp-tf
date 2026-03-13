output "instance_name" {
  value = module.compute_instance.instance_name
}

output "instances_self_links" {
  value = module.compute_instance.instances_self_links
}

output "instance_template_self_link" {
  value = module.instance_template.self_link_unique
}

output "data_disk_layout" {
  value = local.additional_disks
}
