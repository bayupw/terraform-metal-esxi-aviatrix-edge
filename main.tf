# Retrieve Equinix Metal project data
data "equinix_metal_project" "this" {
  name = var.metal_project_name
}

# Provision ESXi host
resource "equinix_metal_device" "this" {
  hostname         = var.esx_hostname
  plan             = var.plan
  metro            = var.metro
  operating_system = var.os
  billing_cycle    = var.billing
  project_id       = data.equinix_metal_project.this.id
}

# Set Network to Hybrid
resource "equinix_metal_device_network_type" "this" {
  device_id = equinix_metal_device.this.id
  type      = "hybrid"

  depends_on = [equinix_metal_device.this]
}

# Create VLANs
resource "equinix_metal_vlan" "this" {
  for_each = var.vlans

  metro       = var.metro
  project_id  = data.equinix_metal_project.this.id
  vxlan       = each.value.id
  description = each.value.description

  depends_on = [equinix_metal_device.this]
}

# Add VLANs to bond0
resource "equinix_metal_port_vlan_attachment" "this" {
  for_each = var.vlans

  device_id = metal_device_network_type.this.device_id
  port_name = "bond0"
  vlan_vnid = each.value.id

  depends_on = [equinix_metal_device.this]
}

# Reserve a Public IP block
resource "equinix_metal_reserved_ip_block" "this" {
  project_id = data.equinix_metal_project.this.id
  type       = "public_ipv4"
  metro      = var.metro
  quantity   = var.num_public_ip

  depends_on = [equinix_metal_device.this]
}

# Create a Metal Gateway
resource "equinix_metal_gateway" "gateway" {
  project_id        = data.equinix_metal_project.this.id
  vlan_id           = equinix_metal_vlan.this["internet_vlan"].id
  ip_reservation_id = equinix_metal_reserved_ip_block.this.id
}