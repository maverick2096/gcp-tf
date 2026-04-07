variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone where the Rancher VMs live"
  type        = string
}

variable "network" {
  description = "VPC network name"
  type        = string
}

variable "node_names" {
  description = "Names of the 3 pre-existing Rancher VMs"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "health_check_port" {
  description = "TCP port the LB health checker probes"
  type        = number
}

variable "session_affinity" {
  description = "LB session affinity mode"
  type        = string
}

variable "network_tier" {
  description = "GCP network tier (PREMIUM or STANDARD)"
  type        = string
}

variable "health_check_intervals" {
  description = "Health check timing"
  type = object({
    check_interval_sec  = number
    timeout_sec         = number
    healthy_threshold   = number
    unhealthy_threshold = number
  })
}
