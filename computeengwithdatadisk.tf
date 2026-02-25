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
  vm_name = "xxxxcmvltma01"

  disks = {
    opt_commvault = { mount = "/opt/Commvault",   size = 128, type = "pd-balanced" }
    commvault_ddb = { mount = "/commvault_ddb",   size = 300, type = "pd-ssd"      }
    commvault_idx = { mount = "/commvault_index", size = 250, type = "pd-ssd"      }
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
}        mount      = d.mount
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
