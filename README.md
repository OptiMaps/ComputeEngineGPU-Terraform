# ComputeEngineGPU-Terraform
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

Create google cloud GPU server with Terraform

## Overview
If you are running this script, you will get this cloud resource
* AWS S3
* AWS DynamoDB
* GCP Virtual Private Cloud
* GCP Compute Engine with n1-standard-8 and nvidia-tesla-T4 GPU (this could be changed)
* GCP Cloud Storage

## Architecture
![Group 71](https://github.com/user-attachments/assets/83cd3ae4-7a9a-4ce5-933d-164cc4a45118)

## Prerequisites
```
- Terraform >= 1.10
- AWS CLI configured
- GCP CLI configured
- Github SSH key
- Dockerhub configured
```

## Repository Structure
```
.
├── create_server_with_dynamic_zones.sh
├── credentials.json
├── LICENSE
├── Makefile
├── README.md
├── .env
└── src
    ├── main.tf
    ├── modules
    │   ├── vpc
    │   │   ├── main.tf
    │   │   └── variables.tf
    │   └── worker
    │       ├── main.tf
    │       └── variables.tf
    ├── s3_init
    │   ├── main.tf
    │   ├── provider.tf
    │   ├── terraform.tfstate
    │   └── terraform.tfstate.backup
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    └── variables.tf
```

## Module Documentation

### Networking Module

This module establishes the core VPC infrastructure in Google Cloud Platform (GCP).

#### Resources Created:

**VPC Network (`google_compute_network`):**
- Network name: `rl-vpc-network`
- Configuration:
  - Custom subnet mode enabled (auto-create subnetworks disabled)
  - MTU set to 1460 bytes (GCP standard)

**Subnet (`google_compute_subnetwork`):**
- Subnet name: `my-custom-subnet`
- Configuration:
  - CIDR range: `10.0.1.0/24`
  - Region: Dynamically set via variable
  - Associated with `rl-vpc-network`

**Firewall Rule (`google_compute_firewall`):**
- Rule name: `allow-ingress-from-iap`
- Purpose: Enables SSH access to instances
- Configuration:
  - Protocol: TCP
  - Port: 22 (SSH)
  - Source range: `0.0.0.0/0` (allow from any IP)
  - Direction: INGRESS

#### Usage

To use this module in your Terraform configuration:

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  region = "your-desired-region"
}
```

#### Security Considerations
- The current firewall rule allows SSH access from any IP (`0.0.0.0/0`). Consider restricting this to specific IP ranges for production environments
- Consider implementing additional security measures such as:
  - Cloud NAT for outbound internet access
  - Additional firewall rules for specific services
  - VPC Service Controls

> [!NOTE]
> - The subnet CIDR (`10.0.1.0/24`) provides 254 usable IP addresses
> - Can be extended with additional subnets as needed
> - MTU 1460 is optimized for GCP's network virtualization

### Compute Module

This module provisions a GPU-enabled compute instance in Google Cloud Platform (GCP) configured for deep learning workloads.

#### Instance Configuration (`google_compute_instance`)
- Name: `training-worker-gpu-instance`
- Hardware:
  - Machine type: Configurable via variable
  - GPU: 1x NVIDIA T4 (configurable via `gpu_type` variable)
  - Boot disk: 150GB SSD
  - Image: PyTorch with CUDA 12.4 support (`deeplearning-platform-release/pytorch-latest-cu124`)

#### Network Configuration
- Connected to custom VPC: `rl-vpc-network`
- Subnet: `my-custom-subnet`
- Ephemeral public IP enabled
- Tagged with `ssh-enabled` for firewall rules

#### Security & Access
- SSH access configured via provided SSH keys
- Service account with Google Cloud Storage read/write permissions
- GitHub SSH key deployment for repository access
- Docker Hub authentication configured

#### Instance Scheduling
- Automatic restart disabled
- Non-preemptible instance (for training stability)
- Terminates on host maintenance

#### Provisioning Steps
1. System Updates & Dependencies
   - Updates system packages
   - Installs Git
   - Configures GPU drivers

2. Storage Setup
   - Creates and mounts GCS bucket at `/home/${var.username}/gcs-bucket`
   - Configures appropriate permissions

3. Docker Environment
   - Installs Docker CE and required dependencies
   - Configures Docker service
   - Pulls specified training image (`falconlee236/rl-image:parco-cuda123`)

4. Code Deployment
   - Clones specified Git repository
   - Sets up SSH configurations for GitHub access
   - Copies environment configuration file

#### Usage

```hcl
module "worker" {
  source = "./modules/worker"
  
  machine_type       = "n1-standard-4"
  zone              = "us-central1-a"
  gpu_type          = "nvidia-tesla-t4"
  username          = "your-username"
  ssh_file          = "path/to/ssh/public/key"
  ssh_file_private  = "path/to/ssh/private/key"
  env_file          = "path/to/.env"
  git_ssh_url       = "your-repo-ssh-url"
  dockerhub_id      = "your-dockerhub-id"
  dockerhub_pwd     = "your-dockerhub-password"
}
```

> [!NOTE]
> - Instance is optimized for deep learning workloads with CUDA 12.4 support
> - Automatic backups not configured - consider implementing if needed
> - Consider implementing monitoring and logging solutions
> - Review security configurations before deploying to production


## Usage

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

## State Management

This module sets up the backend infrastructure required for Terraform state management using AWS S3 and DynamoDB.

#### Resources Created:

**S3 Bucket (`aws_s3_bucket`):**
- Bucket name: `sangylee-s3-bucket-tfstate`
- Purpose: Stores Terraform state files
- Configuration:
  - Force destroy enabled for easier cleanup
  - Versioning enabled to maintain state history

**DynamoDB Table (`aws_dynamodb_table`):**
- Table name: `terraform-tfstate-lock`
- Purpose: Provides state locking mechanism to prevent concurrent modifications
- Configuration:
  - Partition key: `LockID` (String)
  - Read capacity: 2 units
  - Write capacity: 2 units

#### Usage

To use this state backend in other Terraform configurations, add the following backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "sangylee-s3-bucket-tfstate"
    key            = "terraform.tfstate"
    region         = "your-region"
    dynamodb_table = "terraform-tfstate-lock"
    encrypt        = true
  }
}
```

> [!NOTE]
> - Ensure proper IAM permissions are configured for access to both S3 and DynamoDB
> - The DynamoDB table uses provisioned capacity mode with minimal read/write units
> - S3 versioning helps maintain state file history and enables recovery if needed


## Security
- Information about security groups
- Network access controls
- Key management
- Sensitive data handling

## Best Practices
- Naming conventions
- Tagging strategy
- Resource organization
- Cost optimization recommendations

## Contributing
Guidelines for contributing to the infrastructure code:
1. Branch naming conventions
2. Commit message format
3. Pull request process
4. Code review requirements

## Operational Notes
- Backup procedures
- Monitoring setup
- Alerting configuration
- Disaster recovery procedures

## Support
Contact information for infrastructure team or maintainers (@falconlee236)
Or Feel Free to send email to me (`falconlee236@gmail.com`)

---

Tips for maintaining this README:
1. Keep it updated with each infrastructure change
2. Include any relevant compliance requirements
3. Document known limitations
4. Add troubleshooting guides for common issues
5. Update version dependencies regularly


## 사용방법
### 처음 사용하는 경우
```bash
make init
```
### 나중에 사용하는 경우
```bash
make
```
### gcp 인스턴스만 삭제하고 싶은 경우
```bash
make clean
```

### aws s3까지 삭제하고 싶은 경우 (완전 초기화)
```bash
make fclean
```

<!--
> [!NOTE]  
> Highlights information that users should take into account, even when skimming.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]  
> Crucial information necessary for users to succeed.

> [!WARNING]  
> Critical content demanding immediate user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.
-->
