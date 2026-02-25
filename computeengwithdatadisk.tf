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
  # Disk map per instance: mount_point -> {size_gb, type}
  instance_disks = {
    xxxxcmvltma01 = {
      opt_commvault = { mount = "/opt/Commvault",     size = 128, type = "pd-balanced" }
      commvault_ddb = { mount = "/commvault_ddb",     size = 300, type = "pd-ssd"      }
      commvault_idx = { mount = "/commvault_index",   size = 250, type = "pd-ssd"      }
    }
    ge4cmvltvsa01 = {
      commvault     = { mount = "/Commvault",         size = 400, type = "pd-balanced" }
      opt_commvault = { mount = "/opt/Commvault",     size = 12,  type = "pd-balanced" }
    }
  }

  # Flatten for disk resources
  disk_list = flatten([
    for vm, disks in local.instance_disks : [
      for k, d in disks : {
        vm         = vm
        disk_key   = k
        mount      = d.mount
        size       = d.size
        type       = d.type
      }
    ]
  ])

  disk_map = {
    for d in local.disk_list : "${d.vm}-${d.disk_key}" => d
  }
}

# Create disks
resource "google_compute_disk" "data" {
  for_each = local.disk_map

  name = "${each.value.vm}-${each.value.disk_key}"
  zone = var.zone
  type = each.value.type
  size = each.value.size

  labels = {
    role = "commvault"
    vm   = each.value.vm
  }
}

# VM 1
resource "google_compute_instance" "vm1" {
  name         = "xxxxcmvltma01"
  zone         = var.zone
  machine_type = var.vm1_machine_type

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

  # Attach disks (VM1)
  dynamic "attached_disk" {
    for_each = {
      for k, v in local.instance_disks.xxxxcmvltma01 :
      k => v
    }
    content {
      source      = google_compute_disk.data["xxxxcmvltma01-${attached_disk.key}"].id
      device_name = "data-${attached_disk.key}"
    }
  }

  metadata_startup_script = templatefile("${path.module}/startup-mount.sh.tftpl", {
    disks = {
      for k, v in local.instance_disks.xxxxcmvltma01 :
      # device_name must match attached_disk.device_name
      "data-${k}" => v.mount
    }
  })
}

# VM 2
resource "google_compute_instance" "vm2" {
  name         = "ge4cmvltvsa01"
  zone         = var.zone
  machine_type = var.vm2_machine_type

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

  # Attach disks (VM2)
  dynamic "attached_disk" {
    for_each = {
      for k, v in local.instance_disks.ge4cmvltvsa01 :
      k => v
    }
    content {
      source      = google_compute_disk.data["ge4cmvltvsa01-${attached_disk.key}"].id
      device_name = "data-${attached_disk.key}"
    }
  }

  metadata_startup_script = templatefile("${path.module}/startup-mount.sh.tftpl", {
    disks = {
      for k, v in local.instance_disks.ge4cmvltvsa01 :
      "data-${k}" => v.mount
    }
  })
}
