# 무작위 ID 출력
output "bucket_name" {
    value = google_storage_bucket.artifact_bucket.name
}