locals {
  additional_disks = [
    for idx, size in var.data_disk_sizes_gb : {
      auto_delete  = var.data_disks_auto_delete
      boot         = false
      device_name  = format("%s-data-%02d", var.hostname, idx + 1)
      disk_size_gb = size
      disk_type    = var.data_disk_type
      mode         = "READ_WRITE"
      disk_labels  = var.data_disk_labels
    }
  ]

  access_config = var.assign_public_ip ? [
    {
      nat_ip       = var.nat_ip
      network_tier = var.network_tier
    }
  ] : []

  service_account = var.service_account_email == null ? null : {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 15.0"

  project_id = var.project_id
  region     = var.region

  name_prefix = var.hostname
  machine_type = var.machine_type

  # Image / boot disk
  source_image         = var.source_image
  source_image_family  = var.source_image_family
  source_image_project = var.source_image_project
  disk_size_gb         = tostring(var.boot_disk_size_gb)
  disk_type            = var.boot_disk_type
  disk_labels          = var.boot_disk_labels
  auto_delete          = tostring(var.boot_disk_auto_delete)

  # Network
  network            = var.network
  subnetwork         = var.subnetwork
  subnetwork_project = var.subnetwork_project
  access_config      = local.access_config

  # Metadata / tags
  metadata       = var.metadata
  startup_script = var.startup_script
  tags           = var.tags
  labels         = var.labels

  # IAM
  service_account = local.service_account

  # Data disks generated from simple size list
  additional_disks = local.additional_disks
}

module "compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 15.0"

  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  hostname            = var.hostname
  add_hostname_suffix = false
  num_instances       = 1

  deletion_protection = var.deletion_protection

  # Use the template created above
  instance_template = module.instance_template.self_link_unique
}
