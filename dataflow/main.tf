resource "google_dataflow_job" "streaming_job" {
  name              = "streaming-dataflow-job"
  template_gcs_path = "gs://dataflow-templates/latest/PubSub_to_BigQuery"

  temp_gcs_location = "gs://${google_storage_bucket.dataflow_temp.name}/temp"

  service_account_email = google_service_account.dataflow_sa.email
  enable_streaming_engine = true
  on_delete = "drain"

  parameters = {
    inputTopic  = "projects/${var.project_id}/topics/my-topic"
    outputTable = "${var.project_id}:dataset.table"
  }

  labels = {
    env     = "prod"
    type    = "streaming"
  }
}
