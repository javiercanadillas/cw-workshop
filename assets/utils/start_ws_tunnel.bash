#!/usr/bin/env bash

cluster_name="${WS_CLUSTER_NAME:-main-cluster}"
config_name="${WS_CONFIG_NAME:-main-config}"
local_port="${WS_LOCAL_PORT:-2222}"
workstation_name="${WS_NAME:-main-workstation}"
project_id="$GCP_PROJECT_ID"
region="${GCP_REGION:-europe-west1}"

open_tunnel() {
  echo "Launching \"gcloud beta workstations start-tcp-tunnel...\" command"
  gcloud beta workstations start-tcp-tunnel \
    --project="$project_id" \
    --region="$region" \
    --cluster="$cluster_name" \
    --config="$config_name" \
    --local-host-port=:"$local_port" \
    "$workstation_name" 22
}

show_info() {
  echo "You can connect to your workstation through VSCode following these steps:
1. Command Palette > Remote-SSH: Connect to Host...
2. Enter \"user@localhost:$local_port\""
}

main() {
  open_tunnel
  show_info
}

main "$@"