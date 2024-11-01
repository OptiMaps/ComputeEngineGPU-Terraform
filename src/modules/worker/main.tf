# modules/worker.tf

resource "google_compute_instance" "gpu_instance" {
    name = "training-worker-gpu-instance"
    // use variables to configure different values
    // 4 virtual gpus and 15GB memory
    machine_type = var.machine_type
    zone = var.zone

    tags = [ "ssh-enabled" ]

    boot_disk {
        initialize_params {
            // pytorch image that works with cuda 12.1
            image = "deeplearning-platform-release/pytorch-latest-cu121"
            type = "pd-ssd"
            size = 150
        }
    }

    // add a single nvidia T4 GPU
    guest_accelerator {
        type = var.gpu_type
        count = 1
    }

    metadata = {
        // path to store ssh keys inside the worker
        ssh-keys = "${var.username}:${trimspace(file(var.ssh_file))}"
        install-nvidia-driver = true
        proxy-mode = "project_editors"
    }

    scheduling {
        // GCP might terminate your instance for maintainance. We don't want it to restart automatically
        automatic_restart = false
        on_host_maintenance = "TERMINATE"
        // Preemptible instances are much cheaper but they might be terminated during a long training session
        preemptible = false
    }

    network_interface {
        network = "rl-vpc-network"
        subnetwork = "my-custom-subnet"
        access_config {
            // Ephemeral IP
        }
    }

    // give read/write access to cloud storage
    service_account {
        scopes = [ "https://www.googleapis.com/auth/devstorage.read_write" ]
    }
    provisioner "file" {
        // We use a provisioner to copy our local ssh key inside the worker. This will be used to authenticate with GitHub.
        source = var.ssh_file_private
        destination = "/home/${var.username}/.ssh/id_ed25519"

        connection {
            type = "ssh"
            user = var.username
            port = 22
            private_key = "${file(var.ssh_file_private)}"
            host = google_compute_instance.gpu_instance.network_interface[0].access_config[0].nat_ip
        }
    }

    provisioner "file" {
        // We use a provisioner to copy our local ssh key inside the worker. This will be used to authenticate with GitHub.
        source = var.env_file
        destination = "/home/${var.username}/.env"

        connection {
            type = "ssh"
            user = var.username
            port = 22
            private_key = "${file(var.ssh_file_private)}"
            host = google_compute_instance.gpu_instance.network_interface[0].access_config[0].nat_ip
        }
    }

    provisioner "remote-exec" {
        // Here we define some init steps we want to run when our instance is created
        inline = [ 
            "sudo apt update && sudo apt upgrade -y",
            "mkdir /home/${var.username}/gcs-bucket", // create mount path for our bucket
            "sudo chown ${var.username}: /home/${var.username}/gcs-bucket",
            "sudo gcsfuse -o allow_other -file-mode=777 -dir-mode=777 rl-artifact-bucket /home/${var.username}/gcs-bucket", // mount our bucket
            "sudo /opt/deeplearning/install-driver.sh", // install required GPU drivers
            "sudo apt install -y git",
            "chmod 400 /home/${var.username}/.ssh/id_ed25519", // allow git to use our ssh key
            "echo 'Host github.com' >> ~/.ssh/config",
            "echo '    StrictHostKeyChecking no' >> ~/.ssh/config",
            "git clone ${var.git_ssh_url}", // clone our application repository
            "cd ~/${var.git_clone_dir}",
            "sudo apt remove docker docker-engine docker.io containerd runc", ## - Old Version Remove
            "sudo apt update && sudo apt upgrade -y", # set up
            "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
            "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt update",
            "sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin",
            "sudo systemctl start docker",
            "sudo systemctl enable docker",
            "echo ${var.dockerhub_pwd} | docker login -u ${var.dockerhub_id} --password-stdin" # dockerhub login
         ]
         connection {
            type = "ssh"
            user = var.username
            port = 22
            private_key = "${file(var.ssh_file_private)}"
            host = google_compute_instance.gpu_instance.network_interface[0].access_config[0].nat_ip
         }
    }
}

/*
단계
1. 121 cuda 버전 성공 (o)
2. github action destory 성공 (x)
3. gcp cloud storage bucket 생성 + 마운트 성공 (o)
4. docker image container volume 수정하는거 성공
5. dockerimage 12.1 버전으로 빌드, push + tag
6. dockerimage 11.7 버전으로 빌드, push + tag
7. github action apply 성공
*/