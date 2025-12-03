locals {
  cloud_build_sa_id = "cloud-build-sa"
}

/* -----------------------------
   Service Account for Cloud Build
   ----------------------------- */

resource "google_service_account" "cloud_build_sa" {
  account_id   = local.cloud_build_sa_id
  display_name = "Cloud Build Service Account"
}

/* -----------------------------
   IAM bindings for the SA
   (Adjust these to your needs)
   ----------------------------- */

# Allow Cloud Build to act as itself
resource "google_project_iam_member" "cloud_build_sa_cloudbuild_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

# Allow pushing to Artifact Registry (or Container Registry)
resource "google_project_iam_member" "cloud_build_sa_artifactregistry" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

# Allow deploying to Cloud Run (optional)
resource "google_project_iam_member" "cloud_build_sa_cloudrun_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

# Allow using service account tokens (for Cloud Run deployment)
resource "google_project_iam_member" "cloud_build_sa_iam_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

# Allow access to GCS if needed
resource "google_project_iam_member" "cloud_build_sa_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

/* -----------------------------
   Cloud Build Trigger (GitHub)
   ----------------------------- */

resource "google_cloudbuildv2_repository" "github_repo" {
  provider = google

  name     = "github-${var.github_owner}-${var.github_repo}"
  parent   = "projects/${var.project_id}/locations/global/connections/github" # ensure this connection exists
  remote_uri = "https://github.com/${var.github_owner}/${var.github_repo}.git"
}

# NOTE: If you're using the older v1 triggers w/ GitHub App, use `google_cloudbuild_trigger` with
# 'github' block instead. Here is a v1 trigger example:

resource "google_cloudbuild_trigger" "github_trigger" {
  name        = "github-${var.github_repo}-on-${var.trigger_branch}"
  description = "Trigger Cloud Build on push to ${var.trigger_branch}"

  github {
    owner                = var.github_owner
    name                 = var.github_repo
    push {
      branch = "^${var.trigger_branch}$"
    }
  }

  # Path to your cloudbuild.yaml in the repo
  filename = "cloudbuild.yaml"

  service_account = google_service_account.cloud_build_sa.email

  substitutions = {
    _ENVIRONMENT = "dev"
  }
}
