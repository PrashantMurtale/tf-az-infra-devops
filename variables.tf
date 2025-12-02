variable "subscription_id" {
  description = "Azure subscription ID. If not provided, will use default subscription from Azure CLI/credentials."
  type        = string
  default     = "927fddb8-9af9-4841-9ddd-633d0716ce3b"
  sensitive   = true
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "Central India"

  validation {
    condition = contains([
      "Central India",
      "South India",
      "West India",
      "East US",
      "East US 2",
      "West US",
      "West US 2",
      "North Central US",
      "South Central US",
      "West Central US",
      "North Europe",
      "West Europe",
      "UK South",
      "UK West"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod). Defaults to terraform workspace."
  type        = string
  default     = null
}

variable "admin_username" {
  description = "Administrator username for the virtual machines"
  type        = string
  default     = "azureuser"

  validation {
    condition     = length(var.admin_username) >= 3 && length(var.admin_username) <= 20
    error_message = "Admin username must be between 3 and 20 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.admin_username))
    error_message = "Admin username can only contain alphanumeric characters, underscores, and hyphens."
  }
}

variable "ssh_public_key" {
  description = "Full path to SSH Public Key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"

  validation {
    condition     = fileexists(var.ssh_public_key)
    error_message = "SSH public key file must exist at the specified path."
  }
}

variable "allowed_source_addresses" {
  description = "List of IP addresses or CIDR blocks allowed to access resources via NSG rules"
  type        = list(string)
  default     = ["*"]

  validation {
    condition     = length(var.allowed_source_addresses) > 0
    error_message = "At least one source address must be specified."
  }
}

variable "vm_size_jenkins" {
  description = "VM size for Jenkins server"
  type        = string
  default     = "Standard_B2ms"
}

variable "vm_size_sonar" {
  description = "VM size for SonarQube/Nexus server"
  type        = string
  default     = "Standard_B2ms"
}

variable "disk_size_jenkins" {
  description = "OS disk size in GB for Jenkins VM"
  type        = number
  default     = 60

  validation {
    condition     = var.disk_size_jenkins >= 30 && var.disk_size_jenkins <= 4095
    error_message = "Disk size must be between 30 and 4095 GB."
  }
}

variable "disk_size_sonar" {
  description = "OS disk size in GB for SonarQube/Nexus VM"
  type        = number
  default     = 80

  validation {
    condition     = var.disk_size_sonar >= 30 && var.disk_size_sonar <= 4095
    error_message = "Disk size must be between 30 and 4095 GB."
  }
}

variable "vm_image_publisher" {
  description = "Publisher for the VM image"
  type        = string
  default     = "Canonical"
}

variable "vm_image_offer" {
  description = "Offer for the VM image"
  type        = string
  default     = "0001-com-ubuntu-server-focal"
}

variable "vm_image_sku" {
  description = "SKU for the VM image"
  type        = string
  default     = "20_04-lts"
}

variable "vm_image_version" {
  description = "Version of the VM image. Use 'latest' with caution."
  type        = string
  default     = "latest"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "enable_availability_zones" {
  description = "Enable availability zones for high availability"
  type        = bool
  default     = false
}

variable "vm_zone" {
  description = "Availability zone for VMs (1, 2, or 3). Ignored if enable_availability_zones is false."
  type        = number
  default     = 1

  validation {
    condition     = var.vm_zone >= 1 && var.vm_zone <= 3
    error_message = "VM zone must be between 1 and 3."
  }
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "Azure DevOps Infrastructure"
}

variable "project_owner" {
  description = "Project owner for tagging"
  type        = string
  default     = "DevOps Team"
}

variable "cost_center" {
  description = "Cost center for tagging"
  type        = string
  default     = "Engineering"
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
