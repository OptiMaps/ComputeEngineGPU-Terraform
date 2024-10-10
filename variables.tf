variable "ssh_file" {
  description = "ssh public key path"
  type = string
  default = "./.ssh/id_ed25519.pub"
}

variable "ssh_file_private" {
  description = "ssh private key path"
  type = string
  default = "./.ssh/id_ed25519"
}

variable "git_ssh_url" {
    description = "git clone url"
    type = string
    default = "https://github.com/OptiMaps/TrainRepo"
}

variable "git_clone_dir" {
    description = "directory path"
    type = string
    default = "TrainRepo"
}

variable "credentials_file" {
    description = "credentials file"
    type = string
    default = "./credentials.json"
}

variable "bucket_url" {
    description = "bucket url"
    type = string
    default = ""
}

variable "project" {
    description = "project name"
    type = string
    default = "optimap-438115"
}

variable "region" {
    description = "region name"
    type = string
    default = "me-west1"
}

variable "zone" {
    description = "zone name"
    type = string
    default = "me-west1-b"
}

variable "machine_type" {
    description = "gpu machine type"
    type = string
    default = "n1-standard-1"
}

variable "gpu_type" {
    description = "gpu type"
    type = string
    default = "nvidia-tesla-t4"
}