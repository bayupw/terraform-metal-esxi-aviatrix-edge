# output "esxcli" {
#   description = "esxcli commands to configure PortGroups on vSwitch0"
#   value       = local.esxcli
# }

output "metal_device_ip" {
  description = "esxi IP"
  value       = equinix_metal_device.this.access_public_ipv4
}

output "metal_device_password" {
  description = "esxi password"
  value       = equinix_metal_device.this.root_password
}

output "metal_gateway_ip" {
  description = "usable_public_ip"
  value       = cidrhost(equinix_metal_reserved_ip_block.this.cidr_notation, 1)
}

output "public_ip_block" {
  description = "public_ip_block"
  value       = equinix_metal_reserved_ip_block.this.cidr_notation
}

output "usable_public_ip" {
  description = "usable_public_ip"
  value       = "${local.first_public_ip} - ${local.last_public_ip}"
}

locals {
  first_public_ip = cidrhost(equinix_metal_reserved_ip_block.this.cidr_notation, 2)
  last_public_ip  = cidrhost(equinix_metal_reserved_ip_block.this.cidr_notation, var.num_public_ip - 2)
}