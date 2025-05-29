
provider "oci" {}

resource "oci_core_instance" "generated_oci_core_instance" {
  for_each = var.instances


  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }

  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id

  create_vnic_details {
    assign_ipv6ip             = "true"
    assign_private_dns_record = "true"
    assign_public_ip          = "true"
    subnet_id                 = var.subnet_id
  }

  display_name = each.key

  instance_options {
    are_legacy_imds_endpoints_disabled = "false"
  }

  is_pv_encryption_in_transit_enabled = "true"

  metadata = {
    "ssh_authorized_keys" = var.ssh_public_key
  }

  shape = "VM.Standard.A1.Flex"

  shape_config {
    memory_in_gbs = each.value.memory_in_gbs
    ocpus         = each.value.ocpus
  }

  source_details {
    source_id   = var.oci_image_source
    source_type = "image"
  }
}


# Output the public IP addresses of the instances
output "instance_ips" {
  value = {
    for instance_name, instance in oci_core_instance.generated_oci_core_instance :
    
    instance_name => {
      ipv4_public = instance.public_ip
      ipv4_private = instance.private_ip
      # ipv6_ip = instance.vnics[0].ipv6_ips[0]
    }
  }
}
