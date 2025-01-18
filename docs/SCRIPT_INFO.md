# 🚀 Dynamic GPU Provisioning Script for Terraform

Automates the deployment of GPU-enabled servers on Google Cloud Platform (GCP) by dynamically identifying available zones for both CPU and GPU resources.


## 📖 Overview
This script streamlines the process of deploying GCP Compute Engine instances equipped with NVIDIA Tesla T4 GPUs. It dynamically detects zones where both the required machine type (`n1-standard-8`) and GPU (`nvidia-tesla-t4`) are available, automates Terraform execution, and ensures resilience with error handling.


## ⚙️ Prerequisites

- **Google Cloud CLI (gcloud)** installed and configured
- **Amazon Web Service CLI (aws)** installed and configured  
- **Terraform** installed (>= 1.10)  
- **Make** utility installed  
- **Valid GCP credentials** with compute permissions  


## 🛠️ How It Works

1. **Zone Discovery:**
   - The script compares the available zones for both the CPU (`n1-standard-8`) and GPU (`nvidia-tesla-t4`) using `comm` and `gcloud` commands.
   - Overlapping zones where both resources are available are stored in an array.

2. **Dynamic Deployment:**
   - Iterates over the discovered zones.
   - Sets the `TF_VAR_region` and `TF_VAR_zone` environment variables for Terraform.
   - Executes `make` to trigger the Terraform workflow.

3. **Error Handling:**
   - If `make` fails, the script waits for 30 seconds and runs `make clean`.
   - Continues to the next zone if deployment fails.
   - Exits successfully upon the first successful deployment.

## 📂 Project Structure

```
.
├── create_server_with_dynamic_zones.sh  # This script
├── terraform.prod.tfvars                # Dockerhub credentials
├── credentials.json                     # GCP credentials
├── Makefile                             # Terraform commands
├── README.md                            # Project documentation
├── .env                                 # Environment variables
└── src
    ├── main.tf                          # Terraform main config
    ├── provider.tf                      # Terraform provider config
    ├── storage.tf                       # Google cloud storage config
    ├── modules                          # Terraform modules
    │   ├── vpc
    │   │   ├── main.tf
    │   │   └── variables.tf
    │   └── worker
    │       ├── main.tf
    │       └── variables.tf
    └── variables.tf
```

## 🚀 Usage

1. **Configure GCP Authentication:**
   ```bash
   gcloud auth login
   gcloud config set project [YOUR_PROJECT_ID]
   ```

2. **Run the Script:**
   ```bash
   bash create_server_with_dynamic_zones.sh
   ```

3. **Monitor Deployment:**
   - The script will attempt deployment in available zones.
   - If successful, the script exits.
   - On failure, it retries in the next available zone.

## 🔧 Customization

- **Change GPU Type:**
  Modify the `TF_VAR_machine_type` env in the script:
  ```bash
  export TF_VAR_machine_type="n1-standard-8"
  ```
  Replace with your desired GPU type (e.g., `nvidia-tesla-v100`).

- **Change GPU count:**
  Modify the `TF_VAR_gpu_count` env in the script:
  ```bash
  export TF_VAR_gpu_count=1
  ```
  Replace with the desired GPU count (e.g., `2`).

- **Change CPU Type:**
  Modify the `TF_VAR_gpu_type` env in the script:
  ```bash
  export TF_VAR_gpu_type="nvidia-tesla-t4"
  ```
  Replace with the desired machine type (e.g., `n2-standard-16`).

## 🤝 Support

For any issues or inquiries, please contact **@falconlee236** or email at **falconlee236@gmail.com**.

## 📜 License

This project is licensed under the [Apache 2.0 License](https://opensource.org/licenses/Apache-2.0).
