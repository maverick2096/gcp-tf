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
  description = "VPC network name — used to scope the health check firewall rule"
  type        = string
}

variable "node_names" {
  description = "Names of the 3 pre-existing Rancher VMs"
  type        = list(string)

  validation {
    condition     = length(var.node_names) == 3
    error_message = "Exactly 3 node names are required."
  }
}

variable "name_prefix" {
  description = "Prefix applied to every resource created by this module"
  type        = string
}

variable "health_check_port" {
  description = "TCP port the LB health checker probes on each node"
  type        = number
  default     = 443
}

variable "session_affinity" {
  description = "Session affinity for the backend service. CLIENT_IP pins long-lived connections (e.g. Rancher agent WebSocket) to the same node."
  type        = string
  default     = "CLIENT_IP"

  validation {
    condition     = contains(["NONE", "CLIENT_IP", "CLIENT_IP_PORT_PROTO", "CLIENT_IP_PROTO"], var.session_affinity)
    error_message = "session_affinity must be one of: NONE, CLIENT_IP, CLIENT_IP_PORT_PROTO, CLIENT_IP_PROTO."
  }
}

variable "network_tier" {
  description = "GCP network tier for the static IP and forwarding rules"
  type        = string
  default     = "PREMIUM"

  validation {
    condition     = contains(["PREMIUM", "STANDARD"], var.network_tier)
    error_message = "network_tier must be PREMIUM or STANDARD."
  }
}

variable "health_check_intervals" {
  description = "Health check timing configuration"
  type = object({
    check_interval_sec  = number
    timeout_sec         = number
    healthy_threshold   = number
    unhealthy_threshold = number
  })
  default = {
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}
