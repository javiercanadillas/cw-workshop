# Cloud Workstations Workshop

## Creating the infrastructure

Follow these steps to setup the infrastructure for the workshop:

1. Clone this repo

```bash
git clone https://github.com/javiercanadillas/cw-workshop
```

2. Open a Cloud Shell in your GCP project. You may also use your local machine and a local Cloud SDK installation.

3. Set an environment variable with your project ID:

```bash
export GCP_PROJECT_ID=<PROJECT_ID> # Replace with your project ID
```

If you wish a different Cloud Region other than `europe-west1`, then setup the corresponding environment variable, otherwise you can skip this step:

```bash
export GCP_REGION=<REGION> # Replace with your desired region
```

4. Launch the `bootstrap_demo.bash` script that will launch a Cloud Build pipeline to create the necessary Terraform infrastructure and supporting assets:

```bash 
cd cw-workshop/assets
./bootstrap_lab.bash
```

5. Grab a coffee and wait for the Cloud Build pipeline to finish. It will take around 25 minutes to create the Cloud Workstations Cluster infrastructure.

You can observe the progress of the pipeline in the Cloud Build console.

## Using remote VS Code on your Cloud Workstation

Use the scripts available in the `assets/utils` folder to connect to your Cloud Workstation using remote VS Code:

- `start_vscode.bash`: Sets up a SSH tunnel to your Cloud Workstation in port `$WS_LOCAL_PORT`.
- `start_ws.bash`: Starts the Cloud Workstation from command line.

## Destroying the infrastructure

Use the option `destroy` to destroy the infrastructure:

```bash
cd cw-workshop/assets
./bootstrap_lab.bash destroy
```