output "instance_names"             { value = module.gcp_vm.instance_names }
output "instance_self_links"        { value = module.gcp_vm.instance_self_links }
output "internal_ips"               { value = module.gcp_vm.internal_ips }
output "instance_template_self_link" { value = module.gcp_vm.instance_template_self_link }
output "data_disk_names"            { value = module.gcp_vm.data_disk_names }
output "data_disk_count"            { value = module.gcp_vm.data_disk_count }
