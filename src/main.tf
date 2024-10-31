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
        profile = "falconlee236"
    }
}

provider "google" {
    credentials = file(var.credentials_file)
    project = var.project
    region = var.region
    zone = var.zone
}

provider "aws" {
    region = "ap-northeast-2"
    profile = "falconlee236"
}

module "vpc_network" {
    source = "./modules/vpc"
    
    region = var.region
}

# resource "google_storage_bucket" "artifact_bucket" {
#     name = "model-artifact-bucket"
#     location = "US"
#     force_destroy = true

#     uniform_bucket_level_access = true
# }

module "training_worker" {
    source = "./modules/worker"

    ssh_file = var.ssh_file
    ssh_file_private = var.ssh_file_private
    # bucket_url = var.bucket_url
    git_ssh_url = var.git_ssh_url
    git_clone_dir = var.git_clone_dir
    machine_type = var.machine_type
    gpu_type = var.gpu_type
    zone = var.zone
    username = var.username
    env_file = var.env_file
    dockerhub_id = var.dockerhub_id
    dockerhub_pwd = var.dockerhub_pwd

    depends_on = [ module.vpc_network ]
}