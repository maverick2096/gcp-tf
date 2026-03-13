terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0"
    }
  }
}

provider "google" {
  project = "my-gcp-project-id"
  region  = "asia-south1"
  zone    = "asia-south1-a"
}

provider "google-beta" {
  project = "my-gcp-project-id"
  region  = "asia-south1"
  zone    = "asia-south1-a"
}

module "vm" {
  source = "./modules/gcp-vm-wrapper"

  project_id = "my-gcp-project-id"
  region     = "asia-south1"
  zone       = "asia-south1-a"

  hostname     = "app-vm-01"
  machine_type = "e2-standard-4"

  # Use either network or subnetwork as per your setup.
  network            = ""
  subnetwork         = "projects/my-gcp-project-id/regions/asia-south1/subnetworks/my-subnet"
  subnetwork_project = "my-gcp-project-id"

  # Boot disk
  source_image         = ""
  source_image_family  = "debian-12"
  source_image_project = "debian-cloud"
  boot_disk_size_gb    = 50
  boot_disk_type       = "pd-balanced"
  boot_disk_labels = {
    role = "boot"
  }

  # Data disks:
  # 2 disks example -> [100, 200]
  # 4 disks example -> [100, 200, 500, 1000]
  data_disk_sizes_gb = [100, 200, 500, 1000]
  data_disk_type     = "pd-balanced"
  data_disk_labels = {
    role = "data"
  }
  data_disks_auto_delete = true

  # Networking
  assign_public_ip = false
  nat_ip           = null
  network_tier     = "PREMIUM"

  # Metadata / tags / labels
  metadata = {
    enable-oslogin = "TRUE"
  }

  startup_script = <<-EOT
    #!/bin/bash
    echo "VM is ready" > /tmp/vm-ready.txt
  EOT

  tags = ["ssh", "app"]
  labels = {
    env   = "dev"
    owner = "platform"
  }

  # IAM
  service_account_email = "vm-sa@my-gcp-project-id.iam.gserviceaccount.com"
  service_account_scopes = [
    "cloud-platform"
  ]

  deletion_protection = false
}

output "instance_name" {
  value = module.vm.instance_name
}

output "instance_self_links" {
  value = module.vm.instances_self_links
}

output "data_disk_layout" {
  value = module.vm.data_disk_layout
}  # ── Boot Disk ───────────────────────────────────────────────────────────────
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
