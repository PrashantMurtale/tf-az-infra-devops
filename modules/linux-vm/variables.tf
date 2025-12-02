variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the VM will be created"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to attach the VM to"
  type        = string
}

variable "network_security_group_id" {
  description = "ID of the network security group"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2ms"
}

variable "admin_username" {
  description = "Administrator username for the VM"
  type        = string
}

variable "ssh_public_key" {
  description = "Full path to SSH public key file"
  type        = string
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 60
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for OS disk"
  type        = string
  default     = "Standard_LRS"
}

variable "vm_image_publisher" {
  description = "Publisher of the VM image"
  type        = string
  default     = "Canonical"
}

variable "vm_image_offer" {
  description = "Offer of the VM image"
  type        = string
  default     = "0001-com-ubuntu-server-focal"
}

variable "vm_image_sku" {
  description = "SKU of the VM image"
  type        = string
  default     = "20_04-lts"
}

variable "vm_image_version" {
  description = "Version of the VM image"
  type        = string
  default     = "latest"
}

variable "enable_availability_zones" {
  description = "Enable availability zones"
  type        = bool
  default     = false
}

variable "vm_zone" {
  description = "Availability zone for the VM (1, 2, or 3)"
  type        = number
  default     = 1
}

variable "custom_data" {
  description = "Filename of the custom data script (cloud-init)"
  type        = string
  default     = null
}

variable "custom_data_path" {
  description = "Path to the custom data script directory (relative to root module)"
  type        = string
  default     = "scripts"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

