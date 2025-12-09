resource "google_workflows_workflow" "workflow" {
  name     = var.workflow_name
  region   = var.region
  project  = var.project_id

  description = "Sample GCP Workflow deployed using Terraform"

  service_account = google_service_account.workflow_sa.email

  source_contents = file("${path.module}/workflow.yaml")

  labels = {
    env = "dev"
  }
}
