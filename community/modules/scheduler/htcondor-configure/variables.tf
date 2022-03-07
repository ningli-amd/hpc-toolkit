variable "project_id" {
  description = "Project in which HTCondor pool will be created"
  type        = string
}

variable "deployment_name" {
  description = "Name for HTCondor pool"
  type        = string
}

variable "access_point_roles" {
  description = "Project-wide roles for HTCondor Access Point service account"
  type        = list(string)
  default = [
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    "roles/storage.objectViewer",
  ]
}

variable "central_manager_roles" {
  description = "Project-wide roles for HTCondor Central Manager service account"
  type        = list(string)
  default = [
    "roles/compute.instanceAdmin",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    "roles/storage.objectViewer",
  ]
}

variable "pool_password" {
  description = "HTCondor Pool Password"
  type        = string
  sensitive   = true
  default     = null
}
