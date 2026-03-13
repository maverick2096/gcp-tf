###############################################################################
# Required
###############################################################################

variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The GCP region (e.g. us-central1)."
  type        = string
}

variable "zone" {
  description = "The GCP zone (e.g. us-central1-a)."
  type        = string
}

variable "hostname" {
  description = "Base hostname for the compute instance(s). A numeric suffix is appended when num_instances > 1."
  type        = string
}

variable "subnetwork" {
  description = "Self-link or name of the subnetwork to attach the instance to."
  type        = string
}

###############################################################################
# Networking
###############################################################################

variable "subnetwork_project" {
  description = "Project that owns the subnetwork. Defaults to var.project_id when left empty."
  type        = string
  default     = ""
}

variable "access_config" {
  description = <<-EOT
    Access configurations for external IPs. Pass an empty list [] for internal-only
    (no public IP). Each entry: { nat_ip = string, network_tier = string }.
  EOT
  type = list(object({
    nat_ip       = string
    network_tier = string
  }))
  default = []
}

variable "tags" {
  description = "Network tags for firewall rule targeting."
  type        = list(string)
  default     = []
}

###############################################################################
# Machine & Image
###############################################################################

variable "machine_type" {
  description = "Compute Engine machine type (e.g. e2-medium, n2-standard-4)."
  type        = string
  default     = "e2-medium"
}

variable "source_image_family" {
  description = "OS image family (e.g. debian-12, ubuntu-2204-lts)."
  type        = string
  default     = "debian-12"
}

variable "source_image_project" {
  description = "GCP project that hosts the OS image."
  type        = string
  default     = "debian-cloud"
}

###############################################################################
# Boot Disk
###############################################################################

variable "disk_size_gb" {
  description = "Boot disk size in GB."
  type        = number
  default     = 50
}

variable "disk_type" {
  description = "Boot disk type: pd-standard | pd-balanced | pd-ssd."
  type        = string
  default     = "pd-balanced"
}

###############################################################################
# Additional / Data Disks
#
# Declare one object per data disk you want attached to every instance.
# Only disk_size_gb is required; all other fields are optional.
#
# Example — 2 data disks (sizes only):
#   additional_disks = [
#     { disk_size_gb = 100 },
#     { disk_size_gb = 200 },
#   ]
#
# Example — 4 data disks with explicit types and names:
#   additional_disks = [
#     { disk_size_gb = 100, disk_type = "pd-balanced", disk_name = "app-1" },
#     { disk_size_gb = 100, disk_type = "pd-balanced", disk_name = "app-2" },
#     { disk_size_gb = 500, disk_type = "pd-ssd",      disk_name = "db-1" },
#     { disk_size_gb = 500, disk_type = "pd-ssd",      disk_name = "db-2" },
#   ]
###############################################################################

variable "additional_disks" {
  description = <<-EOT
    List of additional data disks to attach to every instance.
    Each entry maps to one persistent disk in the instance template.
    disk_size_gb is the only required field.
  EOT
  type = list(object({
    disk_size_gb = number
    disk_name    = optional(string, null)
    device_name  = optional(string, null)
    disk_type    = optional(string, "pd-balanced")
    auto_delete  = optional(bool, true)
    disk_labels  = optional(map(string), {})
  }))
  default = []

  validation {
    condition     = alltrue([for d in var.additional_disks : d.disk_size_gb > 0])
    error_message = "Every additional disk must have disk_size_gb greater than 0."
  }
}

###############################################################################
# Scaling
###############################################################################

variable "num_instances" {
  description = "Number of identical instances to create from the same template."
  type        = number
  default     = 1
}

###############################################################################
# IAM / Service Account
###############################################################################

variable "service_account" {
  description = <<-EOT
    Service account to attach to the instance.
    See: https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account
  EOT
  type = object({
    email  = string
    scopes = list(string)
  })
  default = {
    email  = ""
    scopes = ["cloud-platform"]
  }
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
  description = "Bash startup script executed on first boot."
  type        = string
  default     = ""
}

variable "enable_oslogin" {
  description = "Inject enable-oslogin=TRUE into instance metadata for IAM-based SSH access."
  type        = bool
  default     = true
}

###############################################################################
# Misc
###############################################################################

variable "deletion_protection" {
  description = "Prevent accidental deletion of instances via the GCP console or API."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels (key/value pairs) applied to all created resources."
  type        = map(string)
  default     = {}
}
