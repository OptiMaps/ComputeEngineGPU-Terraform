# 무작위 ID 생성
resource "random_id" "bucket_suffix" {
    byte_length = 4
}

resource "google_storage_bucket" "artifact_bucket" {
    # bucket name must be globally unique with all users
    name = "rl-artifact-bucket-${random_id.bucket_suffix.hex}"
    location = var.region
    
    force_destroy = true
    uniform_bucket_level_access = true
}