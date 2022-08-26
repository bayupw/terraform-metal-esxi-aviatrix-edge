# Terraform to deploy VMware ESXi at Equinix Metal for Aviatrix Edge

This repository provides a Terraform code that deploys ESXi host in Equinix Metal for hosting Aviatrix Edge
- Create VLANs
- Provision ESXi host(s)
- Set network to hybrid
- Add VLANs to bond0 interface
- Reserve a /29 public IP block (/29 is the minimum for Metal Gateway)
- Create a Metal Gateway for Internet access

The code provided is for demo purposes only.

## Prerequisites

Please make sure you have:
- [Equinix Metal account](https://metal.equinix.com/developers/docs/accounts/users/#profile)
- [Equinix Metal project](https://metal.equinix.com/developers/docs/accounts/projects/)
- [Equinix Metal API key or authentication token](https://metal.equinix.com/developers/docs/accounts/users/#api-keys)

To run this project, you will need to edit the terraform.tfvars file and set the following environment variables

Variables | Description
--- | ---
METAL_AUTH_TOKEN | Equinix API Key or Authentication Token

## Run Locally

Clone the project

```bash
git clone https://github.com/bayupw/terraform-metal-esxi-aviatrix-edge
```

Go to the project directory

```bash
cd terraform-metal-esxi-aviatrix-edge
```

Set environment variables

```bash
export METAL_AUTH_TOKEN="EqU1n1Xm3T4l4UtHt0K3n"
```

Terraform workflow

```bash
terraform init
terraform plan
terraform apply -auto-approve
```