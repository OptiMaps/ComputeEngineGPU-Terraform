# How to USE?
> [!IMPORTANT]
> You must follow this guide using this script.

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

## Prerequisite Setting
### 1. AWS (S3, DynamoDB)
1. create aws account
2. create aws IAM account access key 
![image](https://github.com/user-attachments/assets/5388ae28-2d90-4fc1-b15a-dc3d0761f01d)
![image](https://github.com/user-attachments/assets/75ce1e54-82d6-46ec-ae47-3358ec50afc4)

3. install aws cli
For detailed installation instructions, please refer to the official AWS CLI documentation [here](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/getting-started-install.html).
### 2. Google Cloud
1. create google account
2. add billing account to google cloud platform (for getting 300$ credits)
3. Upgrade free trial account to paid [Cloud Billing account](https://cloud.google.com/free/docs/free-cloud-features?hl=en). (for using GPU resources)
4. Create new project
![image](https://github.com/user-attachments/assets/117612b6-3d17-4187-8ab7-e2a59cf03e42)
5. Create Service account 
![image](https://github.com/user-attachments/assets/9d4acc36-f7aa-4c5d-a657-08a42d884201)
![image](https://github.com/user-attachments/assets/06770bc7-4848-4e0d-bc6e-190ca8cc7b01)
> [!CAUTION]
> You must set appropriate authority. IF you was confused which authority was better, Set the owner option.
6. Generate Service account Json key
![image](https://github.com/user-attachments/assets/288f4e6f-ac9e-4231-9723-eeb34af5411e)
> [!IMPORTANT]
> You must save this json file. This file will be used soon.
7. Set the Google Cloud Compute Engine API
![image](https://github.com/user-attachments/assets/979e8017-7d09-4a29-a3f7-27116ff8cb85)
![image](https://github.com/user-attachments/assets/84c7be2b-1a9d-4478-a9fd-234952aad8f8)
8. Increase GPU Quota
![image](https://github.com/user-attachments/assets/25b30bcf-1ec0-4034-8692-6d082512a0ec)
![image](https://github.com/user-attachments/assets/5151ad60-a538-444e-b12d-fff4202bfb63)
![image](https://github.com/user-attachments/assets/7e808b0d-01c5-41cc-bd43-21237d3a757f)
![image](https://github.com/user-attachments/assets/b21517f6-00aa-4c8a-96f1-120cceb9089d)
> [!IMPORTANT]
> IF you do not increase gpu quota, you will not get gpu resource when creating compute engine with gpu.
### 3. Dockerhub 
1. create [dockerhub](https://hub.docker.com/) account
### 4. Add ssh key to github
1. generate ssh key in local -> [guide](https://docs.github.com/ko/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
2. add ssh key to github -> [guide](https://docs.github.com/ko/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
### 5. Install terraform
1. install terraform [cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Getting Started
### 1. set aws account to aws cli
```bash
aws configure --profile [your_profile_name]
> AWS Access Key ID [None]: [your id]
> AWS Secret Access Key [None]: [your secret key]
```
if Your setting is correct, you will show this screen
```bash
☁  ComputeEngineGPU-Terraform [main] cat ~/.aws/credentials
[your_profile_name]
aws_access_key_id = [your id]
aws_secret_access_key = [your secret key]
```
### 2. set google cloud cli
```bash
gcloud auth activate-service-account --key-file=./credentials.json
```
if Your setting is correct, you will show this screen
```bash
☁  ComputeEngineGPU-Terraform [main] gcloud auth list
                  Credentialed Accounts
ACTIVE  ACCOUNT
*       q2o3481298347123-compute@developer.gserviceaccount.com
```
> [!IMPORTANT]
> your credentials.json must be root directory and must follow that name.

### 3. set .ssh file
In previous setting section, move root directory to create pub key and private key wrapping .ssh directory in chapter 4
```bash
☁  ComputeEngineGPU-Terraform [main] ll .ssh  
total 8.0K
-rw------- 1 sangylee sangylee 419 Oct 11 00:18 id_ed25519
-rw-r--r-- 1 sangylee sangylee 104 Oct 11 00:18 id_ed25519.pub
```

> [!IMPORTANT]
> your .ssh must be root directory and must follow that name.

### 4. default gcp project setting
Open ./variables.tf, change default value (project, username) to your own enviroment

> [!CAUTION]
> project name must specify numbers after project name dash (-)

### 5. create terraform.prod.tfvars 
create `terraform.prod.tfvars` in root directory and contents is following
```hcl
dockerhub_id = "your docker hub id"
dockerhub_pwd = "yout docker hub pwd"
```

> [!IMPORTANT]
> `terraform.prod.tfvars` is secret file. so you must not upload that files. I already add `terraform.prod.tfvars` files in gitignore

### 6. change aws profile
You must change your aws profile name following downscript
`./main.tf`
```bash
terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "4.49.0"
        }
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
    backend s3 {
        bucket         = "sangylee-s3-bucket-tfstate" # S3 버킷 이름
        key            = "terraform.tfstate" # tfstate 저장 경로
        region         = "ap-northeast-2"
        dynamodb_table = "terraform-tfstate-lock" # dynamodb table 이름
        profile = "(your aws profile name)" <--- change
    }
}
```
`./provider.tf
```
provider "google" {
    credentials = file(var.credentials_file)
    project = var.project
    region = var.region
    zone = var.zone
}

provider "aws" {
    region = "ap-northeast-2"
    profile = "(your aws profile name)" <--- change
}
```

`./s3_init/provider.tf
```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
    region = "ap-northeast-2"
    profile = "(your aws profile name)" <--- change
}
```
### 7. Initialize Terraform
```bash
make init
```
this command init s3 and dynamoDB with [terraform backend](https://developer.hashicorp.com/terraform/language/backend)

### 8. Deploy server
```
sudo chmod +x create_server_with_dynamic_zones.sh
bash ./create_server_with_dynamic_zones.sh
```

## how to change option?
If you want to change the following configurations, please refer to the information below:
* [GPU Type](https://cloud.google.com/compute/docs/gpus?hl=en)
* [CPU Type](https://cloud.google.com/compute/docs/general-purpose-machines?hl=en)
in `create_server_with_dynamic_zones.sh`
change this line's filter name, you can change option
```bash
done < <(comm -12 <(gcloud compute machine-types list --filter="name=[your machine type]" | grep asia | awk '{print $2}' | sort | uniq) <(gcloud compute accelerator-types list --filter="name=[your gpu type]" | grep asia | awk '{print $2}' | sort | uniq))
```
For more information, please visit [Dynamic GPU Provisioning Script for Terraform](SCRIPT_INFO.md).


