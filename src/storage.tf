resource "google_storage_bucket" "artifact_bucket" {
    # bucket name must be globally unique with all users
    name = "rl-artifact-bucket"
    location = var.region
    
    force_destroy = true
    uniform_bucket_level_access = true
}