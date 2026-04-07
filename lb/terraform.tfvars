# ─────────────────────────────────────────────────────────────────────────────
# All runtime values live here — no values are hardcoded in .tf files.
# Do not commit this file to source control if it is environment-specific.
# Use separate tfvars files per environment: dev.tfvars, prod.tfvars etc.
# ─────────────────────────────────────────────────────────────────────────────

project_id  = "your-gcp-project-id"
region      = "us-central1"
zone        = "us-central1-a"
network     = "default"
name_prefix = "rancher"

node_names = [
  "rancher-node-1",
  "rancher-node-2",
  "rancher-node-3",
]

# LB health check — TCP connect on this port to decide if a node is healthy
health_check_port = 443

# Pin long-lived connections (Rancher agent WebSocket) to the same node
session_affinity = "CLIENT_IP"

# PREMIUM = Google's global backbone, lower latency. STANDARD = cheaper.
network_tier = "PREMIUM"

# Tune health check sensitivity
health_check_intervals = {
  check_interval_sec  = 10  # probe every 10s
  timeout_sec         = 5   # wait 5s for response
  healthy_threshold   = 2   # 2 consecutive passes → healthy
  unhealthy_threshold = 3   # 3 consecutive fails  → removed from pool
}
