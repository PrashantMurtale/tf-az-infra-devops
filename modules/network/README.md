# Network Module

This module creates Azure networking resources including resource group, virtual network, subnet, and network security group.

## Usage

```hcl
module "network" {
  source = "./modules/network"

  resource_prefix        = local.resource_prefix
  location               = var.location
  vnet_address_space     = var.vnet_address_space
  subnet_address_prefixes = var.subnet_address_prefixes
  common_tags            = local.common_tags
  nsg_rules              = local.nsg_rules
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 4.50.0 |

## Resources Created

- Resource Group
- Virtual Network
- Subnet
- Network Security Group (with dynamic security rules)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| resource_prefix | Prefix for resource names | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| vnet_address_space | VNet address space | `list(string)` | `["10.0.0.0/16"]` | no |
| subnet_address_prefixes | Subnet address prefixes | `list(string)` | `["10.0.1.0/24"]` | no |
| common_tags | Common tags | `map(string)` | `{}` | no |
| nsg_rules | NSG security rules | `list(object)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_name | Resource group name |
| resource_group_id | Resource group ID |
| virtual_network_name | VNet name |
| virtual_network_id | VNet ID |
| subnet_id | Subnet ID |
| network_security_group_id | NSG ID |

