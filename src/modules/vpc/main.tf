# modules/vpc.tf

resource "google_compute_network" "vpc_network" {
    name = "rl-vpc-network"
    auto_create_subnetworks = false
    mtu = 1460
}

resource "google_compute_subnetwork" "default" {
    name = "my-custom-subnet"
    ip_cidr_range = "10.0.1.0/24"
    region = var.region
    network = google_compute_network.vpc_network.id
}

// create a firewall rules to allow SSH ingress
resource "google_compute_firewall" "allow_ingress" {
    name = "allow-ingress-from-iap"
    network = google_compute_network.vpc_network.id

    allow {
        protocol = "tcp"
        ports = [ "22" ]
    }

    // Allow incoming connections
    source_ranges = [ "0.0.0.0/0" ]
    direction = "INGRESS"
}