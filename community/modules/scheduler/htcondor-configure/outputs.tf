output "access_point_service_account" {
  description = "HTCondor Access Point Service Account (e-mail format)"
  value       = module.access_point_service_account.email
  depends_on = [
    google_secret_manager_secret_iam_member.access_point
  ]
}

output "central_manager_service_account" {
  description = "HTCondor Central Manager Service Account (e-mail format)"
  value       = module.central_manager_service_account.email
  depends_on = [
    google_secret_manager_secret_iam_member.central_manager
  ]
}

output "pool_password_secret_id" {
  description = "Google Cloud Secret Manager ID containing HTCondor Pool Password"
  value       = google_secret_manager_secret.pool_password.secret_id
  sensitive   = true
}

output "central_manager_runners" {
  description = "Toolkit Runner to configure an HTCondor Central Manager"
  value       = local.central_manager_runners
}

output "access_point_runners" {
  description = "Toolkit Runner to configure an HTCondor Access Point"
  value       = local.access_point_runners
}
