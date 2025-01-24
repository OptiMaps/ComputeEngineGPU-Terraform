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

output "user_name" {
    value = var.username
}

output "sample_proxy_command" {
    value = "gcloud compute ssh --zone ${var.zone} --project ${var.project} %h --ssh-flag='-W %h:%p'"
}