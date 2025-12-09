resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["ssh", "http"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = google_compute_network.vpc.name

    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  labels = {
    env = "dev"
    app = "demo"
  }
}
