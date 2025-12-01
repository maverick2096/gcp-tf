resource "google_bigquery_dataset" "this" {
  dataset_id                  = var.dataset_id
  friendly_name               = "Analytics Dataset"
  description                 = "Dataset for analytics workloads created via Terraform"
  location                    = var.location          # e.g. "US" or "EU"
  delete_contents_on_destroy  = true                  # careful in prod!
  default_table_expiration_ms = 2592000000           # 30 days (optional)
}

resource "google_bigquery_table" "events" {
  dataset_id = google_bigquery_dataset.this.dataset_id
  table_id   = "user_events"

  friendly_name = "User Events"
  description   = "Raw user events"
  deletion_protection = false

  schema = file("${path.module}/schema.json")

  time_partitioning {
    type  = "DAY"
    field = "event_timestamp"
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
