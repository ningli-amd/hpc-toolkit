/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


locals {
  resource_prefix = var.name_prefix != null ? var.name_prefix : "${var.deployment_name}-client"

  user_startup_script_runners = var.startup_script == null ? [] : [
    {
      type        = "shell"
      content     = var.startup_script
      destination = "user_startup_script.sh"
    }
  ]

  configure_nvidia_driver_runners = var.install_nvidia_driver == false ? [] : [
    {
      type        = "ansible-local"
      content     = file("${path.module}/scripts/configure-grid-drivers.yml")
      destination = "/usr/local/ghpc/configure-grid-drivers.yml"
    }
  ]

  configure_chrome_remote_desktop_runners = var.configure_chrome_remote_desktop == false ? [] : [
    {
      type        = "ansible-local"
      content     = file("${path.module}/scripts/configure-chrome-desktop.yml")
      destination = "/usr/local/ghpc/configure-chrome-desktop.yml"
    }
  ]

  driver     = { install-nvidia-driver = var.install_nvidia_driver }
  logging    = var.enable_google_logging ? { google-logging-enable = 1 } : { google-logging-enable = 0 }
  monitoring = var.enable_google_monitoring ? { google-monitoring-enable = 1 } : { google-monitoring-enable = 0 }
  metadata   = merge(local.driver, local.logging, local.monitoring, var.metadata)
}

module "client_startup_script" {
  source = "github.com/GoogleCloudPlatform/hpc-toolkit//modules/scripts/startup-script?ref=1b1cdb0"

  deployment_name = var.deployment_name
  project_id      = var.project_id
  region          = var.region
  labels          = var.labels

  runners = flatten([
    local.user_startup_script_runners, local.configure_nvidia_driver_runners, local.configure_chrome_remote_desktop_runners
  ])
}

module "instances" {
  source = "github.com/GoogleCloudPlatform/hpc-toolkit//modules/compute/vm-instance?ref=264e99c"

  instance_count = var.instance_count
  spot           = var.spot

  deployment_name = var.deployment_name
  name_prefix     = local.resource_prefix
  project_id      = var.project_id
  region          = var.region
  zone            = var.zone
  labels          = var.labels

  machine_type    = var.machine_type
  service_account = var.service_account
  metadata        = local.metadata
  startup_script  = module.client_startup_script.startup_script
  enable_oslogin  = var.enable_oslogin

  instance_image        = var.instance_image
  disk_size_gb          = var.disk_size_gb
  disk_type             = var.disk_type
  auto_delete_boot_disk = var.auto_delete_boot_disk

  disable_public_ips   = !var.enable_public_ips
  network_self_link    = var.network_self_link
  subnetwork_self_link = var.subnetwork_self_link
  network_interfaces   = var.network_interfaces
  bandwidth_tier       = var.bandwidth_tier
  tags                 = var.tags

  threads_per_core    = var.threads_per_core
  guest_accelerator   = var.guest_accelerator
  on_host_maintenance = var.on_host_maintenance

  network_storage = var.network_storage

}
