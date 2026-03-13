###############################################################################
# GCP Compute Instance Module
# Source: terraform-google-modules/vm/google//modules/compute_instance
# Registry: https://registry.terraform.io/modules/terraform-google-modules/vm/google
###############################################################################

module "compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 11.0"

  region            = var.region
  zone              = var.zone
  subnetwork        = var.subnetwork
  num_instances     = var.num_instances
  hostname          = var.instance_name
  instance_template = module.instance_template.self_link
}

###############################################################################
# Instance Template (required by compute_instance module)
###############################################################################

###############################################################################
# Local: normalise additional_disks into the shape expected by instance_template
# The upstream module wants:
#   additional_disks = list(object({
#     disk_name, device_name, auto_delete, boot,
#     disk_size_gb, disk_type, disk_labels,
#     disk_encryption_key, source_snapshot, interface, mode
#   }))
# We fill every optional field so the caller only has to supply disk_size_gb.
###############################################################################

locals {
  additional_disks_normalised = [
    for idx, d in var.additional_disks : {
      disk_name           = d.disk_name != null ? d.disk_name : "${var.instance_name}-data-${idx + 1}"
      device_name         = d.device_name != null ? d.device_name : "${var.instance_name}-data-${idx + 1}"
      auto_delete         = d.auto_delete
      boot                = false
      disk_size_gb        = d.disk_size_gb
      disk_type           = d.disk_type
      disk_labels         = merge(var.labels, d.disk_labels)
      disk_encryption_key = null
      source_snapshot     = null
      interface           = "SCSI"
      mode                = "READ_WRITE"
    }
  ]
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 11.0"

  project_id           = var.project_id
  region               = var.region
  machine_type         = var.machine_type
  source_image_family  = var.image_family
  source_image_project = var.image_project
  disk_size_gb         = var.disk_size_gb
  disk_type            = var.disk_type
  auto_delete          = true

  # -------------------------------------------------------------------
  # Data disks — one entry per disk the caller declared in
  # var.additional_disks.  Empty list = no extra disks (default).
  # -------------------------------------------------------------------
  additional_disks = local.additional_disks_normalised

  network    = var.network
  subnetwork = var.subnetwork

  service_account = {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  tags   = var.network_tags
  labels = var.labels

  metadata = merge(
    var.metadata,
    var.enable_oslogin ? { enable-oslogin = "TRUE" } : {}
  )

  startup_script = var.startup_script
}
