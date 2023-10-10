terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.81.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.81.0"
    }
  }

  backend "gcs" {
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.zone
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.zone
}

## Enable the services
resource "google_project_service" "enabled_services" {
  project            = var.gcp_project_id
  service            = each.key
  for_each           = toset(var.gcp_services_list)
  disable_on_destroy = false
}

## Define the network and subnetwork
resource "google_compute_network" "default" {
  name                    = "workstation-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  network       = google_compute_network.default.name
  name          = "workstation-subnetwork"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.gcp_region
}

## Define the workstation cluster
resource "google_workstations_workstation_cluster" "default" {
  provider               = google-beta
  workstation_cluster_id = var.ws_cluster_name
  network                = google_compute_network.default.id
  subnetwork             = google_compute_subnetwork.default.id
  location               = var.gcp_region
}


## Define the workstation config
resource "google_workstations_workstation_config" "default" {
  provider               = google-beta
  workstation_config_id  = var.ws_config["name"]
  workstation_cluster_id = google_workstations_workstation_cluster.default.workstation_cluster_id
  location               = var.gcp_region

  idle_timeout    = var.ws_config["idle_timeout"]
  running_timeout = var.ws_config["running_timeout"]

  host {
    gce_instance {
      machine_type                = "e2-standard-4"
      boot_disk_size_gb           = 35
      disable_public_ip_addresses = false
      pool_size = 1
    }
  }

  container {
    image = var.ws_config["image"]
  }
}

## Define the workstation
resource "google_workstations_workstation" "default" {
  provider               = google-beta
  workstation_id         = var.ws_name
  workstation_config_id  = google_workstations_workstation_config.default.workstation_config_id
  workstation_cluster_id = google_workstations_workstation_cluster.default.workstation_cluster_id
  location               = var.gcp_region

  labels = {
    "profile" = "internal-dev"
  }
}

## Set the IAM  binding
resource "google_workstations_workstation_iam_member" "member" {
  provider = google-beta
  project = var.gcp_project_id
  location = var.gcp_region
  workstation_cluster_id = google_workstations_workstation.default.workstation_cluster_id
  workstation_config_id = google_workstations_workstation.default.workstation_config_id
  workstation_id = google_workstations_workstation.default.workstation_id
  role = "roles/workstations.user"
  member = "user:${var.user_email}"
}