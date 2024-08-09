terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.88"
    }
  }
}

# Configure the Yandex Cloud provider
provider "yandex" {
  token     = "your_token" # Your Yandex Cloud OAuth token
  cloud_id  = "your_cloud-id" # Your Yandex Cloud ID
  folder_id = "your_folder-id" # Your Yandex Cloud Folder ID
  zone      = "your_zone" # The zone where resources will be created
}

# Create a compute instance for the build node
resource "yandex_compute_instance" "build_node" {
  name        = "build-node" # Instance name
  platform_id = "standard-v3" # Platform type
  resources {
    cores  = 4 # Number of CPU cores
    memory = 4 # Memory in GB
  }
  boot_disk {
    initialize_params {
      image_id = "fd88m3uah9t47loeseir" # Image ID for the operating system
      size     = 30 # Disk size in GB
      type     = "network-ssd" # Disk type
 }
  }
  network_interface {
    subnet_id = "fl8h2bv6lfj7hqei7bf5" # Subnet ID to attach the instance to
    nat       = true # Enable NAT for external access
  }

  # Metadata for configuring the instance
  metadata = {
    ssh-keys = "jenkins:${file("/var/lib/jenkins/.ssh/id_rsa.pub")}" # Add Jenkins SSH key for access
    user-data = <<-EOF
      #cloud-config
      users:
        - name: jenkins # Create a user named 'jenkins'
          sudo: ALL=(ALL) NOPASSWD:ALL # Grant sudo privileges
          shell: /bin/bash # Set the default shell
          ssh_authorized_keys:
            - ${file("/var/lib/jenkins/.ssh/id_rsa.pub")} # Add Jenkins SSH key
      EOF
 }
}

# Create a compute instance for the production node
resource "yandex_compute_instance" "prod_node" {
  name        = "prod-node" # Instance name
  platform_id = "standard-v3" # Platform type
  resources {
    cores  = 4 # Number of CPU cores
    memory = 4 # Memory in GB
  }
  boot_disk {
    initialize_params {
      image_id = "fd88m3uah9t47loeseir" # Image ID for the operating system
      size     = 30 # Disk size in GB
      type     = "network-ssd" # Disk type
    }
  }
  network_interface {
    subnet_id = "fl8h2bv6lfj7hqei7bf5" # Subnet ID to attach the instance to
    nat       = true # Enable NAT for external access
  }

  # Metadata for configuring the instance
  metadata = {
    ssh-keys = "jenkins:${file("/var/lib/jenkins/.ssh/id_rsa.pub")}" # Add Jenkins SSH key for access
    user-data = <<-EOF
      #cloud-config
      users:
        - name: jenkins # Create a user named 'jenkins'
          sudo: ALL=(ALL) NOPASSWD:ALL # Grant sudo privileges
          shell: /bin/bash # Set the default shell
          ssh_authorized_keys:
            - ${file("/var/lib/jenkins/.ssh/id_rsa.pub")} # Add Jenkins SSH key
      EOF
 }
}

# Output the public IP address of the build node
output "build_node_ip" {
  value = yandex_compute_instance.build_node.network_interface.0.nat_ip_address
}

# Output the public IP address of the production node
output "prod_node_ip" {
  value = yandex_compute_instance.prod_node.network_interface.0.nat_ip_address
}
