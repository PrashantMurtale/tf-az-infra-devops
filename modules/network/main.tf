##############################
# Resource Group
##############################
resource "azurerm_resource_group" "main" {
  name     = "${var.resource_prefix}-rg"
  location = var.location

  tags = var.common_tags
}

##############################
# Virtual Network
##############################
resource "azurerm_virtual_network" "main" {
  name                = "${var.resource_prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space

  tags = var.common_tags
}

##############################
# Subnet
##############################
resource "azurerm_subnet" "main" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_prefixes
}

##############################
# Network Security Group
##############################
resource "azurerm_network_security_group" "main" {
  name                = "${var.resource_prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      # Use source_address_prefix for wildcard "*", source_address_prefixes for specific IPs
      source_address_prefix      = length(security_rule.value.source_address_prefixes) == 1 && security_rule.value.source_address_prefixes[0] == "*" ? "*" : null
      source_address_prefixes    = length(security_rule.value.source_address_prefixes) == 1 && security_rule.value.source_address_prefixes[0] == "*" ? null : security_rule.value.source_address_prefixes
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = security_rule.value.description
    }
  }

  tags = var.common_tags
}

