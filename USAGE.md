### Initialize Terraform
```bash
terraform init
```

### Deploy to Development
```bash
# Switch to dev workspace
terraform workspace select dev

# Plan changes
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply changes
terraform apply -var-file="environments/dev/terraform.tfvars"
```

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ssh_file | SSH public key path | string | "../.ssh/id_ed25519.pub" | yes |
| ssh_file_private | SSH private key path | string | "../.ssh/id_ed25519" | yes |
| env_file | Environment file path | string | "../.env" | yes |
| git_ssh_url | Git clone URL | string | "https://github.com/OptiMaps/TrainRepo" | yes |
| git_clone_dir | Directory path for cloned repository | string | "TrainRepo" | yes |
| credentials_file | GCP credentials file path | string | "../credentials.json" | yes |
| project | GCP project name | string | "optimap-438115" | yes |
| region | GCP region name | string | "asia-east1" | yes |
| zone | GCP zone name | string | "asia-east1-c" | yes |
| machine_type | GCP machine type | string | "n1-standard-8" | yes |
| gpu_type | GPU type | string | "nvidia-tesla-t4" | yes |
| username | Google email ID | string | "sangyleegcp1" | yes |
| dockerhub_id | Docker Hub username | string | n/a | yes |
| dockerhub_pwd | Docker Hub password | string | n/a | yes |

> [!WARNING]
> The `dockerhub_id` and `dockerhub_pwd` variables have no default values and must be provided when applying the Terraform configuration.
