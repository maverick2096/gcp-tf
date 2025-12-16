module "complete_vertex_ai_workbench" {
  source  = "GoogleCloudPlatform/vertex-ai/google//modules/workbench"
  version = "~> 2.0"

  name         = "complete-vertex-ai-workbench"
  location     = var.location
  project_id   = var.project_id
  machine_type = "e2-standard-2"

  kms_key         = module.kms.keys["test"]
  disk_encryption = "CMEK"

  disable_public_ip    = true
  disable_proxy_access = false
  enable_ip_forwarding = false
  tags                 = ["abc", "def"]

  data_disks = [
    {
      disk_size_gb = 330
      disk_type    = "PD_BALANCED"
    },
  ]

  network_interfaces = [
    {
      network  = module.test-vpc-module.network_id
      subnet   = module.test-vpc-module.subnets_ids[0]
      nic_type = "GVNIC"
    }
  ]

  ## https://cloud.google.com/vertex-ai/docs/workbench/instances/manage-metadata
  metadata_configs = {
    post-startup-script          = "${module.metadata_gcs_bucket.url}/${google_storage_bucket_object.startup_script.name}"
    post-startup-script-behavior = "download_and_run_every_start"
    idle-timeout-seconds         = 3600
    notebook-disable-root        = true
    notebook-upgrade-schedule    = "00 19 * * SAT"
    serial-port-logging-enable   = false
    report-event-health          = true
    enable-guest-attributes      = true
  }

  shielded_instance_config = {
    enable_secure_boot = true
  }

  depends_on = [
    google_project_iam_member.workbench_sa,
    google_storage_bucket_iam_member.member,
    google_kms_crypto_key_iam_member.sa_notebooks,
    google_kms_crypto_key_iam_member.sa_aiplatform,
    google_kms_crypto_key_iam_member.sa_compute_engine,
    google_storage_bucket_object.startup_script,
    module.cloud_router,
    google_service_account_iam_member.instance_owner_sa_role,
  ]

}
