variable "project" {
  type        = string
  description = "The ID of the project in which the resource belongs"
  default     = "playground-s-11-c5a153db"
}

variable "zone" {
  type        = string
  description = "The zone that the resources should be created in"
  default     = "us-central1-a"
}

variable "google_service_account_display_name" {
  type        = string
  description = "Service account to attach to the instance"
  default     = "Compute Engine default service account"
}


variable "kubernetes_master" {
  type        = map(any)
  description = "(optional) describe your variable"
  default = {
    name         = "master",
    machine_type = "n1-standard-2",
  }
}

variable "kubernetes_worker" {
  type        = map(any)
  description = "(optional) describe your variable"
  default = {
    name         = "worker",
    machine_type = "n1-standard-2",
  }
}

variable "network_tag" {
  type        = list(string)
  description = "A list of network tags to attach to the instance."
  default     = ["kubernetes"]
}

variable "os_disk" {
  type        = map(any)
  description = "The image from which to initialize this disk"
  default = {
    image = "ubuntu-2004-lts",
    size  = "20"
  }
}

variable "metadata" {
  type        = map(string)
  description = "Metadata key/value pairs to make available from within the instance"
  default = {
    createdby = "terraform",
    env       = "k8s"
  }
}
