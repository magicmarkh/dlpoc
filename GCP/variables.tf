variable "availability_zone" {
  default = "us-central1-a"
  description = "GCP Availability Zone"
}

variable "instance_subnetwork" {
  default = "projects/cyberark-sca/regions/us-central1/subnetworks/default"
  description = "subnetwork for compute instances"
}

variable "linux_image" {
  default = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230812"
  description = "image version"
}