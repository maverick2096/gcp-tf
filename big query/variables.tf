variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Default region for resources (not BigQuery location)"
  default     = "us-central1"
}

variable "location" {
  type        = string
  description = "BigQuery dataset location, e.g. US, EU, asia-south1"
  default     = "US"
}

variable "dataset_id" {
  type        = string
  description = "Dataset ID (no spaces)"
  default     = "analytics_dataset"
}

variable "environment" {
  type        = string
  description = "Environment tag"
  default     = "dev"
}

variable "viewer_email" {
  type        = string
  description = "User email to grant dataset viewer role"
  default     = "someone@example.com"
}
