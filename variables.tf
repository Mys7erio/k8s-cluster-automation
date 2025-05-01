variable "ssh_public_key" {
  description = "Public SSH key for instance access"
  type        = string
}

variable "availability_domain" {
  description = "The availability domain to launch the instance"
  type        = string
}

variable "compartment_id" {
  description = "The compartment id to launch the instance"
  type        = string
}

variable "subnet_id" {
  description = "The Subnet to put the resources in"
  type        = string
}


variable "oci_image_source" {
  description = "The source image for creating the VM"
  type        = string
}


variable "instance_names" {
  description = "Unique instance names to created. This also controls the number of instances created."
  type        = list(string)
}
