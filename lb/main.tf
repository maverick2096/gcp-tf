terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "rancher_lb" {
  source = "./modules/rancher-lb"

  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  network      = var.network
  node_names   = var.node_names
  name_prefix  = var.name_prefix

  health_check_port      = var.health_check_port
  health_check_intervals = var.health_check_intervals
  session_affinity       = var.session_affinity
  network_tier           = var.network_tier
}
