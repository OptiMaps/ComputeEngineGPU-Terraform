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