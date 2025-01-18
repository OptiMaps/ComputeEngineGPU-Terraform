terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "4.49.0"
        }
        # aws = {
        #     source  = "hashicorp/aws"
        #     version = "~> 4.0"
        # }
    }
    # backend s3 {
    #     bucket         = "sangylee-s3-bucket-tfstate" # S3 버킷 이름
    #     key            = "terraform.tfstate" # tfstate 저장 경로
    #     region         = "ap-northeast-2"
    #     dynamodb_table = "terraform-tfstate-lock" # dynamodb table 이름
    #     profile        = "falconlee236"
    # }
}
# terraform init --reconfigure

module "vpc_network" {
    source = "./modules/vpc"
    region = var.region
}

module "training_worker" {
    source = "./modules/worker"

    ssh_file = var.ssh_file
    ssh_file_private = var.ssh_file_private
    git_ssh_url = var.git_ssh_url
    git_clone_dir = var.git_clone_dir
    machine_type = var.machine_type
    gpu_type = var.gpu_type
    gpu_count = var.gpu_count
    zone = var.zone
    username = var.username
    env_file = var.env_file
    dockerhub_id = var.dockerhub_id
    dockerhub_pwd = var.dockerhub_pwd

    depends_on = [ module.vpc_network, google_storage_bucket.artifact_bucket ]
}