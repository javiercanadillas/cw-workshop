#!/usr/bin/env bash
## bootstrap_lab.bash: Launch the infrastucture automation

## Prevent this script from being sourced
#shellcheck disable=SC2317
return 0  2>/dev/null || :

## Main Script vars
# shellcheck disable=SC2128
script_name=$(basename "$BASH_SOURCE")
#shellcheck disable=SC2128
if [[ "$OSTYPE" == "darwin"* ]]; then
  hash greadlink || { echo "Please, install greadlink and try again."; exit 1; }
  script_dir=$(dirname "$(greadlink -f "$BASH_SOURCE")")
else # assume Linux
  script_dir=$(dirname "$(readlink --canonicalize --no-newline "$BASH_SOURCE")")
fi

# This directory is one level up from the "assets" directory where this script should be seating
workdir=$(dirname "$script_dir")
infra_subdir="infra"
tf_command="apply"


## Look & feel related vars
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

## Format info messages with script name in green
info() {
  echo "${green}${script_name}${reset}: ${1}" >&2
}

## Format error messages with script name in red
error() {
  echo "${red}${script_name}${reset}: ${1}" >&2
}

## Check that project ID and region have been set by the user
main-check_env() {
  info "Checking environment configuration..."
  [[ -z ${GCP_PROJECT_ID+x} ]] &&
    { error "Project ID has not been set. Please, run \"export GCP_PROJECT_ID=<project_id>\" and try again."
      exit 1
    }
  gcloud config set project "$GCP_PROJECT_ID" --quiet 2> /dev/null || 
    {
      error "Error trying to read Project ID."
      exit 1
    }
  GCP_REGION=${GCP_REGION:-europe-west1}
  ZONE=${ZONE:-europe-west1-b}
}

## Set up Cloud Build SA permissions so the pipeline can run sucessfully
main-set_cloudbuild_sa() {
  info "Setting the right permissions for Cloud Build, this may take a while..."

  gcloud services enable \
    cloudbuild.googleapis.com \
    cloudresourcemanager.googleapis.com \
    --quiet 1>&2 || {
  error "Failed to enable Cloud Build API"
    exit 1
  }

  local -r cloudbuild_sa="$(gcloud projects describe "$GCP_PROJECT_ID" \
    --format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"
  
  declare -a roles_list=( 'editor'
                          'resourcemanager.projectIamAdmin'
                          'iam.serviceAccountUser'
                          'artifactregistry.repoAdmin'
                          'workstations.admin' )
  
  for role in "${roles_list[@]}"; do
    gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" \
    --member serviceAccount:"$cloudbuild_sa" \
    --role "roles/${role}" --quiet 1>&2 || {
      error "Failed to assign role $role to Cloud Build Service Account"
      exit 1
    }
  done
}

# Launch the Cloud Build pipeline to terraform the required infrastructure
main-launch_pipeline() {
  local -r tf_command="${1:-apply}" && shift

  info "Launching Cloud Build lab bootstrapping pipeline with Terraform $tf_command command ..."
  
  gcloud builds submit "$workdir/assets/$infra_subdir" \
    --substitutions="_GCP_PROJECT_ID=$GCP_PROJECT_ID,_GCP_REGION=$GCP_REGION,_TF_COMMAND=$tf_command" \
    --config="${workdir}/assets/cloudbuild.yaml"
}

main() {
  main-check_env
  main-set_cloudbuild_sa
  main-launch_pipeline "$@"
}

main "$@"