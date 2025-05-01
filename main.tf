
provider "oci" {}

resource "oci_core_instance" "generated_oci_core_instance" {
  for_each = var.instance_names


  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }

  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  create_vnic_details {
    assign_ipv6ip             = "false"
    assign_private_dns_record = "true"
    assign_public_ip          = "true"
    subnet_id                 = var.subnet_id
  }

  display_name = "Red1"

  instance_options {
    are_legacy_imds_endpoints_disabled = "false"
  }

  is_pv_encryption_in_transit_enabled = "true"

  metadata = {
    "ssh_authorized_keys" = var.ssh_public_key
  }

  shape = "VM.Standard.A1.Flex"

  shape_config {
    memory_in_gbs = "6"
    ocpus         = "1"
  }

  source_details {
    source_id   = var.oci_image_source
    source_type = "image"
  }
}


# Output the public IP addresses of the instances
output "instance_public_ips" {
  value = { for instance in oci_core_instance.generated_oci_core_instance : instance.key => instance.value.public_ip }
  description = "Public IPs of the instances"
}

# Output the private IP addresses of the instances
output "instance_private_ips" {
  value = { for instance in oci_core_instance.generated_oci_core_instance : instance.key => instance.value.private_ip }
  description = "Private IPs of the instances"
}