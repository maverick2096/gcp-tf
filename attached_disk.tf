resource "google_compute_attached_disk" "attach" {
  for_each = local.disks

  instance    = google_compute_instance.this.name
  zone        = var.zone
  disk        = google_compute_disk.data[each.key].name
  device_name = "data-${each.key}"
}
