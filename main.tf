# Retrieve Equinix Metal project data
data "metal_project" "project" {
  name = var.metal_project_name
}

# Create VLANs
resource "metal_vlan" "vlans" {
  for_each = var.vlans

  metro       = var.metro
  project_id  = data.metal_project.project.id
  vxlan       = each.value.id
  description = each.value.description
}

# Provision ESXi host(s)
resource "metal_device" "esxi_hosts" {
  for_each = var.hosts

  hostname         = each.value
  plan             = var.plan
  metro            = var.metro
  operating_system = var.os
  billing_cycle    = var.billing
  project_id       = data.metal_project.project.id

  depends_on = [metal_vlan.vlans]
}

# Set Network to Hybrid
resource "metal_device_network_type" "esxi_hosts" {
  for_each = metal_device.esxi_hosts

  device_id = each.value.id
  type      = "hybrid"

  depends_on = [metal_device.esxi_hosts]
}

# Add VLANs to bond0
resource "metal_port_vlan_attachment" "vlans" {
  for_each = {
    for host_vlan in local.host_vlans : "${host_vlan.host_id}:${host_vlan.vlan_id}" => host_vlan
  }

  device_id = each.value.host_id
  port_name = "bond0"
  vlan_vnid = each.value.vlan_id

  depends_on = [metal_device_network_type.esxi_hosts]
}

# Reserve a Public IP block
resource "metal_reserved_ip_block" "public_ip_block" {
  project_id = data.metal_project.project.id
  type       = "public_ipv4"
  metro      = var.metro
  quantity   = var.num_public_ip

  depends_on = [metal_device.esxi_hosts]
}

# Create a Metal Gateway
resource "metal_gateway" "gateway" {
  project_id        = data.metal_project.project.id
  vlan_id           = metal_vlan.vlans["internet_vlan"].id
  ip_reservation_id = metal_reserved_ip_block.public_ip_block.id

  depends_on = [metal_reserved_ip_block.public_ip_block]
}