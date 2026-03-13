###############################################################################
# Required Variables
###############################################################################

variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The GCP region for the instance (e.g. us-central1)."
  type        = string
}

variable "zone" {
  description = "The GCP zone for the instance (e.g. us-central1-a)."
  type        = string
}

variable "instance_name" {
  description = "Base name for the compute instance(s)."
  type        = string
}

variable "network" {
  description = "The self-link or name of the VPC network."
  type        = string
}

variable "subnetwork" {
  description = "The self-link or name of the subnetwork."
  type        = string
}

###############################################################################
# Machine & Image
###############################################################################

variable "machine_type" {
  description = "The machine type for the instance."
  type        = string
  default     = "e2-medium"
}

variable "image_family" {
  description = "The OS image family (e.g. debian-12, ubuntu-2204-lts)."
  type        = string
  default     = "debian-12"
}

variable "image_project" {
  description = "The GCP project that hosts the OS image."
  type        = string
  default     = "debian-cloud"
}

###############################################################################
# Disk
###############################################################################

variable "disk_size_gb" {
  description = "Boot disk size in GB."
  type        = number
  default     = 50
}

variable "disk_type" {
  description = "Boot disk type (pd-standard, pd-ssd, pd-balanced)."
  type        = string
  default     = "pd-balanced"
}

# ------------------------------------------------------------------------------
# Additional / data disks
#
# Provide a list of objects — one entry per data disk you want attached.
# Only `disk_size_gb` is required per entry; all other fields have defaults.
#
# Example — 2 data disks:
#   additional_disks = [
#     { disk_size_gb = 100 },
#     { disk_size_gb = 200, disk_type = "pd-ssd", disk_name = "db-data" }
#   ]
#
# Example — 4 data disks (size-only shorthand):
#   additional_disks = [
#     { disk_size_gb = 100 },
#     { disk_size_gb = 100 },
#     { disk_size_gb = 500 },
#     { disk_size_gb = 500 },
#   ]
# ------------------------------------------------------------------------------
variable "additional_disks" {
  description = <<-EOT
    List of additional data disks to create and attach to every instance.
    Each element maps to one persistent disk in the instance template.
    Only disk_size_gb is required; the rest are optional with sensible defaults.
  EOT

  type = list(object({
    disk_size_gb    = number                  # required — size in GB
    disk_name       = optional(string, null)  # auto-named if null
    device_name     = optional(string, null)  # OS device path hint
    disk_type       = optional(string, "pd-balanced")
    auto_delete     = optional(bool, true)
    disk_labels     = optional(map(string), {})
  }))

  default = []

  validation {
    condition     = alltrue([for d in var.additional_disks : d.disk_size_gb > 0])
    error_message = "Each additional disk must have disk_size_gb > 0."
  }
}

###############################################################################
# Scaling
###############################################################################

variable "num_instances" {
  description = "Number of identical instances to create."
  type        = number
  default     = 1
}

###############################################################################
# IAM / Service Account
###############################################################################

variable "service_account_email" {
  description = "Service account email to attach to the instance. Uses default SA if empty."
  type        = string
  default     = ""
}

variable "service_account_scopes" {
  description = "OAuth2 scopes granted to the service account."
  type        = list(string)
  default     = ["cloud-platform"]
}

###############################################################################
# Networking
###############################################################################

variable "network_tags" {
  description = "Network tags applied to the instance for firewall targeting."
  type        = list(string)
  default     = []
}

###############################################################################
# Metadata & Startup
###############################################################################

variable "metadata" {
  description = "Key/value metadata pairs to set on the instance."
  type        = map(string)
  default     = {}
}

variable "startup_script" {
  description = "Bash startup script to run on first boot."
  type        = string
  default     = ""
}

variable "enable_oslogin" {
  description = "Enable OS Login for SSH access management via IAM."
  type        = bool
  default     = true
}

###############################################################################
# Labels
###############################################################################

variable "labels" {
  description = "Labels (key/value) to apply to all resources."
  type        = map(string)
  default     = {}
}
