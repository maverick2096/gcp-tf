###############################################################################
# Root / Caller main.tf
# All values are passed directly in the module invocation block.
###############################################################################

terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "google" {
  project = "my-gcp-project"
  region  = "us-central1"
}

module "gcp_vm" {
  source = "./gcp-vm-module"

  # ── Required ────────────────────────────────────────────────────────────────
  project_id = "my-gcp-project"
  region     = "us-central1"
  zone       = "us-central1-a"
  hostname   = "my-vm"
  subnetwork = "projects/my-gcp-project/regions/us-central1/subnetworks/default"

  # ── Machine & OS ────────────────────────────────────────────────────────────
  machine_type         = "e2-medium"
  source_image_family  = "debian-12"
  source_image_project = "debian-cloud"

  # ── Boot Disk ───────────────────────────────────────────────────────────────
  disk_size_gb = 50
  disk_type    = "pd-balanced"

  # ── Additional Data Disks ───────────────────────────────────────────────────
  # Add or remove objects to control how many disks are created.
  # Only disk_size_gb is required per entry.
  additional_disks = [
    { disk_size_gb = 100 },
    { disk_size_gb = 200 },
  ]

  # 4-disk example:
  # additional_disks = [
  #   { disk_size_gb = 100, disk_type = "pd-balanced", disk_name = "app-data-1" },
  #   { disk_size_gb = 100, disk_type = "pd-balanced", disk_name = "app-data-2" },
  #   { disk_size_gb = 500, disk_type = "pd-ssd",      disk_name = "db-data-1"  },
  #   { disk_size_gb = 500, disk_type = "pd-ssd",      disk_name = "db-data-2"  },
  # ]

  # ── Scaling ─────────────────────────────────────────────────────────────────
  num_instances = 1

  # ── IAM / Service Account ───────────────────────────────────────────────────
  service_account = {
    email  = ""                  # leave empty for the default Compute SA
    scopes = ["cloud-platform"]
  }

  # ── Networking ──────────────────────────────────────────────────────────────
  subnetwork_project  = ""       # set if using Shared VPC
  access_config       = []       # [] = no public IP; add entry for external IP
  tags                = ["allow-ssh"]
  deletion_protection = false

  # ── Metadata & Startup ──────────────────────────────────────────────────────
  enable_oslogin = true
  metadata       = {}
  startup_script = <<-SCRIPT
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable --now nginx
  SCRIPT

  # ── Labels ──────────────────────────────────────────────────────────────────
  labels = {
    env     = "dev"
    team    = "platform"
    managed = "terraform"
  }
}
