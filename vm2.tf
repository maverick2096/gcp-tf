terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  vm_name = "ge4cmvltvsa01"

  disks = {
    commvault     = { mount = "/Commvault",     size = 400, type = "pd-balanced" }
    opt_commvault = { mount = "/opt/Commvault", size = 12,  type = "pd-balanced" }
  }
}

resource "google_compute_disk" "data" {
  for_each = local.disks

  name = "${local.vm_name}-${each.key}"
  zone = var.zone
  type = each.value.type
  size = each.value.size

  labels = {
    role = "commvault"
    vm   = local.vm_name
  }
}

resource "google_compute_instance" "this" {
  name         = local.vm_name
  zone         = var.zone
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.boot_disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  dynamic "attached_disk" {
    for_each = local.disks
    content {
      source      = google_compute_disk.data[attached_disk.key].id
      device_name = "data-${attached_disk.key}"
    }
  }

  metadata_startup_script = templatefile("${path.module}/startup-mount.sh.tftpl", {
    disks = {
      for k, v in local.disks :
      "data-${k}" => v.mount
    }
  })

  labels = {
    role = "commvault"
    name = local.vm_name
  }
}
