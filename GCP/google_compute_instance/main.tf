# gcloud auth login

# gcloud projects list

# PROJECT=$(gcloud projects list | grep playground | cut -d ' ' -f 1)
# gcloud config set project $PROJECT

# gcloud iam service-accounts list

# gcloud auth application-default set-quota-project playground-s-11-22befb10 

##########
# variable 
##########

variable "project" {
  type        = string
  description = "(optional) describe your variable"
  default     = "playground-s-11-bb03928d"
}



###########################
# terraform Google Provider
###########################

provider "google" {
  region  = "us-central1"
  project = var.project
}

#################
# create resource 
#################

resource "google_service_account" "default" {
  account_id   = var.project
  display_name = "Compute Engine default service account"
}

resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
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

  metadata = {
    CreatedBy = "Terraform"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

#$ terraform import google_service_account.my_sa projects/my-project/serviceAccounts/my-sa@my-project.iam.gserviceaccount.com