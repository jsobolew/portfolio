resource "google_project_service" "dataproc-service" {
  for_each                   = toset(["dataproc.googleapis.com", "workflowexecutions.googleapis.com"])
  project                    = var.project_name
  service                    = each.value
  disable_dependent_services = true
}

resource "google_dataproc_workflow_template" "dataproc_workflow_template" {
  depends_on = [google_project_service.dataproc-service]
  project    = var.project_name
  name       = "${var.project_name}-workflow"
  location   = var.region
  placement {
    managed_cluster {
      cluster_name = "${var.project_name}-cluster"
      config {
        staging_bucket = var.staging_bucket
        master_config {
          num_instances = 1
          machine_type  = "n1-standard-2"
          disk_config {
            boot_disk_size_gb = 30
          }
        }
        worker_config {
          num_instances = 2
          machine_type  = "n1-standard-2"
          disk_config {
            boot_disk_size_gb = 30
          }
        }
        software_config {
          image_version = "2.0.27-ubuntu18"
          properties = {
            "dataproc:dataproc.logging.stackdriver.enable"            = "true"
            "dataproc:dataproc.logging.stackdriver.job.driver.enable" = "true"
            "dataproc:jobs.file-backed-output.enable"                 = "true"
          }
        }
      }
    }
  }
  jobs {
    step_id = "${var.project_name}-job"
    pyspark_job {
      main_python_file_uri = var.py_file
    }

  }
}