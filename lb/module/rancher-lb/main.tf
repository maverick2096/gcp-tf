# ─────────────────────────────────────────────────────────────────────────────
# Module: rancher-lb
# Creates a GCP Regional External Passthrough Network Load Balancer
# in front of 3 pre-existing Rancher VMs.
#
# Resources created:
#   - Static external IP
#   - Regional health check (TCP)
#   - Unmanaged instance group  (read-only reference to existing VMs)
#   - Regional backend service  (TCP passthrough — no TLS termination at LB)
#   - Forwarding rule: port 80  (HTTP  → nginx-ingress on node)
#   - Forwarding rule: port 443 (HTTPS → nginx-ingress on node)
#   - Forwarding rule: port 6443 (RKE2 K8s API server)
#   - Firewall rule  (allow GCP health checker probes)
# ─────────────────────────────────────────────────────────────────────────────

# ── Look up pre-existing VMs (read-only — nothing is modified) ────────────────
data "google_compute_instance" "rancher_nodes" {
  for_each = toset(var.node_names)
  name     = each.value
  zone     = var.zone
  project  = var.project_id
}

# ── Static external IP ────────────────────────────────────────────────────────
resource "google_compute_address" "lb" {
  name         = "${var.name_prefix}-lb-ip"
  project      = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = var.network_tier
  description  = "Static external IP for the ${var.name_prefix} load balancer"
}

# ── Health check ──────────────────────────────────────────────────────────────
resource "google_compute_region_health_check" "lb" {
  name    = "${var.name_prefix}-health-check"
  project = var.project_id
  region  = var.region

  description = "TCP health check — probes port ${var.health_check_port} on each Rancher node"

  tcp_health_check {
    port = var.health_check_port
  }

  check_interval_sec  = var.health_check_intervals.check_interval_sec
  timeout_sec         = var.health_check_intervals.timeout_sec
  healthy_threshold   = var.health_check_intervals.healthy_threshold
  unhealthy_threshold = var.health_check_intervals.unhealthy_threshold
}

# ── Instance group ────────────────────────────────────────────────────────────
resource "google_compute_instance_group" "lb" {
  name        = "${var.name_prefix}-instance-group"
  project     = var.project_id
  zone        = var.zone
  description = "Unmanaged instance group for ${var.name_prefix} nodes"

  instances = [
    for node in data.google_compute_instance.rancher_nodes : node.self_link
  ]

  named_port {
    name = "http"
    port = 80
  }
  named_port {
    name = "https"
    port = 443
  }
  named_port {
    name = "k8s-api"
    port = 6443
  }
}

# ── Backend service ───────────────────────────────────────────────────────────
# protocol = UNSPECIFIED → TCP passthrough mode.
# TLS is terminated on the nodes by nginx-ingress, not at the LB.
# This also keeps the K8s API (6443) working — proxy mode breaks it.
resource "google_compute_region_backend_service" "lb" {
  name    = "${var.name_prefix}-backend-service"
  project = var.project_id
  region  = var.region

  description           = "TCP passthrough backend for ${var.name_prefix}"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "UNSPECIFIED"
  session_affinity      = var.session_affinity
  health_checks         = [google_compute_region_health_check.lb.id]

  backend {
    group          = google_compute_instance_group.lb.id
    balancing_mode = "CONNECTION"
  }
}

# ── Forwarding rules (the actual load balancer entry points) ──────────────────
# Each forwarding rule binds a port on the static IP to the backend service.
# Separate rules per port give cleaner naming, independent descriptions,
# and make it easy to add or remove a port without touching the others.

resource "google_compute_forwarding_rule" "http" {
  name    = "${var.name_prefix}-lb-http"
  project = var.project_id
  region  = var.region

  description           = "Port 80 → nginx-ingress (redirects to HTTPS at the node)"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.lb.address
  ip_protocol           = "TCP"
  ports                 = ["80"]
  backend_service       = google_compute_region_backend_service.lb.id
  network_tier          = var.network_tier
}

resource "google_compute_forwarding_rule" "https" {
  name    = "${var.name_prefix}-lb-https"
  project = var.project_id
  region  = var.region

  description           = "Port 443 → Rancher UI / HTTPS ingress"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.lb.address
  ip_protocol           = "TCP"
  ports                 = ["443"]
  backend_service       = google_compute_region_backend_service.lb.id
  network_tier          = var.network_tier
}

resource "google_compute_forwarding_rule" "k8s_api" {
  name    = "${var.name_prefix}-lb-k8s-api"
  project = var.project_id
  region  = var.region

  description           = "Port 6443 → RKE2 K8s API server (kubectl access via LB)"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.lb.address
  ip_protocol           = "TCP"
  ports                 = ["6443"]
  backend_service       = google_compute_region_backend_service.lb.id
  network_tier          = var.network_tier
}

# ── Firewall — allow GCP health checker probes ────────────────────────────────
# Without this rule, health checks always fail → all nodes marked unhealthy
# → LB drops all traffic. The rule is intentionally narrow: only TCP on the
# health check port from GCP's two fixed health checker CIDR ranges.
resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.name_prefix}-allow-health-check"
  project = var.project_id
  network = var.network

  description   = "Allow GCP LB health checker probes to reach ${var.name_prefix} nodes"
  direction     = "INGRESS"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["rancher-node"]

  allow {
    protocol = "tcp"
    ports    = [tostring(var.health_check_port)]
  }
}
