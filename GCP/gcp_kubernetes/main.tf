/*

gcloud auth login

gcloud projects list

PROJECT=$(gcloud projects list | grep playground | cut -d ' ' -f 1) && echo $PROJECT && echo $PROJECT | pbcopy
gcloud config set project $PROJECT

gcloud iam service-accounts list

gcloud auth application-default login
# gcloud auth application-default set-quota-project $PROJECT

*/

##########
# variable 
##########

# variables.tf

###########################
# terraform Google Provider
###########################

provider "google" {
  region  = "us-central1"
  project = var.project
  zone    = var.zone
}

#################
# create resource 
#################

resource "google_service_account" "default" {
  account_id   = var.project
  display_name = var.google_service_account_display_name
}

resource "google_compute_instance" "master" {
  name         = var.kubernetes_master.name
  machine_type = var.kubernetes_master.machine_type

  tags = var.network_tag

  boot_disk {
    initialize_params {
      image = var.os_disk.image
      size  = var.os_disk.size
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = merge(var.metadata, { ssh-keys = "gcp:${tls_private_key.ssh.public_key_openssh}" })

  metadata_startup_script = file("${path.module}/k8s_master.sh")

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "worker" {
  name         = var.kubernetes_worker.name
  machine_type = var.kubernetes_worker.machine_type

  tags = var.network_tag

  boot_disk {
    initialize_params {
      image = var.os_disk.image
      size  = var.os_disk.size
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = merge(var.metadata, { ssh-keys = "gcp:${tls_private_key.ssh.public_key_openssh}" })

  metadata_startup_script = file("${path.module}/k8s_worker.sh")

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "pem_file" {
  filename          = pathexpand("./iamkey.pem")
  file_permission   = "400"
  sensitive_content = tls_private_key.ssh.private_key_pem
}

output "public_ip_master" {
  value = "ssh -i iamkey.pem gcp@${google_compute_instance.master.network_interface.0.access_config.0.nat_ip} -o 'StrictHostKeyChecking=no'"
}

output "public_ip_workder" {
  value = "ssh -i iamkey.pem gcp@${google_compute_instance.worker.network_interface.0.access_config.0.nat_ip} -o 'StrictHostKeyChecking=no'"
}
#$ terraform import google_service_account.my_sa projects/my-project/serviceAccounts/my-sa@my-project.iam.gserviceaccount.com