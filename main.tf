# Data sources
data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

# Locals for common values and naming
locals {
  # Use environment variable if provided, otherwise use terraform workspace
  environment = var.environment != null ? var.environment : terraform.workspace

  # Resource naming prefix
  resource_prefix = "devops-${local.environment}"

  # Common tags applied to all resources
  common_tags = merge(
    {
      Environment = local.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Owner       = var.project_owner
      CostCenter  = var.cost_center
      CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    },
    var.additional_tags
  )

  # NSG Security Rules
  nsg_rules = [
    {
      name                       = "SSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefixes    = var.allowed_source_addresses
      destination_address_prefix = "*"
      description                = "Allow SSH access"
    },
    {
      name                       = "Jenkins"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefixes    = var.allowed_source_addresses
      destination_address_prefix = "*"
      description                = "Allow Jenkins web UI access"
    },
    {
      name                       = "Sonar"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "9000"
      source_address_prefixes    = var.allowed_source_addresses
      destination_address_prefix = "*"
      description                = "Allow SonarQube web UI access"
    },
    {
      name                       = "Nexus"
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8081"
      source_address_prefixes    = var.allowed_source_addresses
      destination_address_prefix = "*"
      description                = "Allow Nexus repository access"
    }
  ]
}

##############################
# Network Module
##############################
module "network" {
  source = "./modules/network"

  resource_prefix         = local.resource_prefix
  location                = var.location
  vnet_address_space      = var.vnet_address_space
  subnet_address_prefixes = var.subnet_address_prefixes
  common_tags             = local.common_tags
  nsg_rules               = local.nsg_rules
}

##############################
# Jenkins VM Module
##############################
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
  vm_image_publisher       = var.vm_image_publisher
  vm_image_offer           = var.vm_image_offer
  vm_image_sku             = var.vm_image_sku
  vm_image_version         = var.vm_image_version
  custom_data              = "jenkins-install.sh"
  custom_data_path         = "${path.module}/scripts"
  enable_availability_zones = var.enable_availability_zones
  vm_zone                  = var.vm_zone
  common_tags              = local.common_tags
}

##############################
# SonarQube/Nexus VM Module
##############################
module "sonar_vm" {
  source = "./modules/linux-vm"

  vm_name                  = "sonar-${local.resource_prefix}"
  resource_group_name      = module.network.resource_group_name
  location                 = var.location
  subnet_id                = module.network.subnet_id
  network_security_group_id = module.network.network_security_group_id
  vm_size                  = var.vm_size_sonar
  admin_username           = var.admin_username
  ssh_public_key           = var.ssh_public_key
  os_disk_size_gb          = var.disk_size_sonar
  vm_image_publisher       = var.vm_image_publisher
  vm_image_offer           = var.vm_image_offer
  vm_image_sku             = var.vm_image_sku
  vm_image_version         = var.vm_image_version
  custom_data              = "sonar-nexus-install.sh"
  custom_data_path         = "${path.module}/scripts"
  enable_availability_zones = var.enable_availability_zones
  vm_zone                  = var.vm_zone
  common_tags              = local.common_tags
}
