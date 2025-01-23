# 무작위 ID 출력
output "bucket_name" {
    value = google_storage_bucket.artifact_bucket.name
}

output "zone_name" {
    value = var.zone
}

output "host_name" {
    value = "training-worker-gpu-instance"
}

output "project_name" {
    value = var.project
}