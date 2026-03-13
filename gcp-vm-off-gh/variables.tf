variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "hostname" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "network" {
  type    = string
  default = ""
}

variable "subnetwork" {
  type = string
}

variable "subnetwork_project" {
  type    = string
  default = ""
}

variable "source_image" {
  type    = string
  default = ""
}

variable "source_image_family" {
  type    = string
  default = "debian-12"
}

variable "source_image_project" {
  type    = string
  default = "debian-cloud"
}

variable "boot_disk_size_gb" {
  type    = number
  default = 50
}

variable "boot_disk_type" {
  type    = string
  default = "pd-balanced"
}

variable "boot_disk_labels" {
  type    = map(string)
  default = {}
}

variable "boot_disk_auto_delete" {
  type    = bool
  default = true
}

variable "data_disk_sizes_gb" {
  type    = list(number)
  default = []

  validation {
    condition     = alltrue([for size in var.data_disk_sizes_gb : size > 0])
    error_message = "Every value in data_disk_sizes_gb must be greater than 0."
  }
}

variable "data_disk_type" {
  type    = string
  default = "pd-balanced"
}

variable "data_disk_labels" {
  type    = map(string)
  default = {}
}

variable "data_disks_auto_delete" {
  type    = bool
  default = true
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "nat_ip" {
  type    = string
  default = null
}

variable "network_tier" {
  type    = string
  default = "PREMIUM"
}

variable "metadata" {
  type    = map(string)
  default = {}
}

variable "startup_script" {
  type    = string
  default = ""
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "service_account_email" {
  type    = string
  default = null
}

variable "service_account_scopes" {
  type    = set(string)
  default = ["cloud-platform"]
}

variable "deletion_protection" {
  type    = bool
  default = false
}
