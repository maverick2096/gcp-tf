variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for GKE"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "my-gke"
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "node_count" {
  description = "Number of nodes"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Node machine type"
  type        = string
  default     = "e2-medium"
}

variable "environment" {
  description = "Environment label"
  type        = string
  default     = "dev"
}

variable "enable_private_nodes" {
  description = "Enable private GKE nodes"
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "GKE release channel"
  type        = string
  default     = "REGULAR"
}
