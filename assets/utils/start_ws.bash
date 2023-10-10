#!/usr/bin/env bash

cluster_name="${WS_CLUSTER_NAME:-main-cluster}"
config_name="${WS_CONFIG_NAME:-main-config}"
workstation_name="${WS_NAME:-main-workstation}"
project_id="$GCP_PROJECT_ID"
region="${GCP_REGION:-europe-west1}"

gcloud beta workstations start "$workstation_name" --cluster="$cluster_name" --config="$config_name" --region="$region" --project="$project_id"
