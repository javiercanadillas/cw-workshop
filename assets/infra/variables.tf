variable gcp_project_id {
  type = string
}

variable "gcp_region" {
  type = string
  default = "europe-west1"
}

variable "zone" {
  type = string
  default = "europe-west1-b"
}

variable "gcp_services_list" {
  type = list(string)
  default = [ "workstations.googleapis.com" ]
}

variable "ws_cluster_name" {
  type = string
  default = "main-cluster"
}

variable "ws_name" {
  type = string
  default = "main-workstation"
}

variable "user_email" {
  type = string
}

variable "ws_config" {
  type = map(string)
  default = {
    "name" = "main-config"
    "idle_timeout" = "600s"
    "running_timeout" = "21600s"
    "image" = "europe-west1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest"
  }
}