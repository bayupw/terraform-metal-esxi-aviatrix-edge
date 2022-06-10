variable "metal_project_name" {
  description = "Equinix Metal Project Name"
  type        = string
}

variable "metro" {
  description = "Location code"
  type        = string
  default     = "sy"
}

variable "plan" {
  description = "Server config"
  type        = string
  default     = "c3.small.x86"
}

variable "os" {
  description = "Operating System"
  type        = string
  default     = "vmware_esxi_7_0"
}

variable "billing" {
  description = "Deploy type"
  type        = string
  default     = "hourly"
}

variable "vlans" {
  description = "map of VLANs"
  type        = map(any)
}

variable "num_public_ip" {
  description = "number of Public IPs"
  type        = number
  default     = 8 # 8 is the minimum required for Metal Gateway
}

variable "hosts" {
  description = "map of ESXi hosts"
  type        = map(any)
}

locals {

  # Create map for adding VLANs to bond interface for each hosts
  host_vlans = flatten([
    for host, device in metal_device_network_type.esxi_hosts : [
      for vlan in var.vlans : {
        host_id = device.device_id
        vlan_id = vlan.id
      }
    ]
  ])

  esxcli = <<EOF
  esxcli network vswitch standard portgroup add --portgroup-name="Internet-VLAN${var.vlans.internet_vlan.id}" --vswitch-name="vSwitch0"
  esxcli network vswitch standard portgroup set --portgroup-name="Internet-VLAN${var.vlans.internet_vlan.id}" --vlan-id=${var.vlans.internet_vlan.id}

  esxcli network vswitch standard portgroup add --portgroup-name="Management-VLAN${var.vlans.edge_mgt_vlan.id}" --vswitch-name="vSwitch0"
  esxcli network vswitch standard portgroup set --portgroup-name="Management-VLAN${var.vlans.edge_mgt_vlan.id}" --vlan-id=${var.vlans.edge_mgt_vlan.id}

  esxcli network vswitch standard portgroup add --portgroup-name="WAN-VLAN${var.vlans.edge_wan_vlan.id}" --vswitch-name="vSwitch0"
  esxcli network vswitch standard portgroup set --portgroup-name="WAN-VLAN${var.vlans.edge_wan_vlan.id}" --vlan-id=${var.vlans.edge_wan_vlan.id}

  esxcli network vswitch standard portgroup add --portgroup-name="LAN-VLAN${var.vlans.edge_lan_vlan.id}" --vswitch-name="vSwitch0"
  esxcli network vswitch standard portgroup set --portgroup-name="LAN-VLAN${var.vlans.edge_lan_vlan.id}" --vlan-id=${var.vlans.edge_lan_vlan.id}

  esxcli network vswitch standard portgroup add --portgroup-name="VM-VLAN${var.vlans.vm_vlan.id}" --vswitch-name="vSwitch0"
  esxcli network vswitch standard portgroup set --portgroup-name="VM-VLAN${var.vlans.vm_vlan.id}" --vlan-id=${var.vlans.vm_vlan.id}

  EOF
}