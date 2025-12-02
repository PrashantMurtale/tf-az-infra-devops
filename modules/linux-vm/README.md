# Linux VM Module

This module creates a Linux virtual machine in Azure with public IP, network interface, and NSG association.

## Usage

```hcl
module "jenkins_vm" {
  source = "./modules/linux-vm"

  vm_name                  = "jenkins-${local.resource_prefix}"
  resource_group_name      = module.network.resource_group_name
  location                 = var.location
  subnet_id                = module.network.subnet_id
  network_security_group_id = module.network.network_security_group_id
  vm_size                  = var.vm_size_jenkins
  admin_username           = var.admin_username
  ssh_public_key           = var.ssh_public_key
  os_disk_size_gb          = var.disk_size_jenkins
  custom_data              = "jenkins-install.sh"
  custom_data_path         = "${path.module}/scripts"
  enable_availability_zones = var.enable_availability_zones
  vm_zone                  = var.vm_zone
  common_tags              = local.common_tags
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 4.50.0 |

## Resources Created

- Public IP (Standard, Static)
- Network Interface
- NSG Association
- Linux Virtual Machine with:
  - System-assigned managed identity
  - OS disk
  - SSH key authentication
  - Optional custom_data (cloud-init)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vm_name | Name of the virtual machine | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| subnet_id | Subnet ID | `string` | n/a | yes |
| network_security_group_id | NSG ID | `string` | n/a | yes |
| vm_size | VM size | `string` | `"Standard_B2ms"` | no |
| admin_username | Admin username | `string` | n/a | yes |
| ssh_public_key | Path to SSH public key | `string` | n/a | yes |
| os_disk_size_gb | OS disk size in GB | `number` | `60` | no |
| custom_data | Custom data script filename | `string` | `null` | no |
| enable_availability_zones | Enable availability zones | `bool` | `false` | no |
| common_tags | Common tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vm_id | VM ID |
| vm_name | VM name |
| vm_private_ip | Private IP address |
| vm_public_ip | Public IP address |
| managed_identity_principal_id | Managed identity principal ID |

