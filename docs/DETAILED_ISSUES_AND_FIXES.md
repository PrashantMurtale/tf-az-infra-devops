# Detailed Terraform Issues and Required Fixes

## File-by-File Analysis

---

## 1. providers.tf

### Critical Issues:

**Line 20:** Hardcoded Subscription ID
```hcl
subscription_id = "927fddb8-9af9-4841-9ddd-633d0716ce3b"
```
**Problem:** 
- Security risk if code is committed to public repo
- Not portable across environments
- Difficult to manage multiple subscriptions

**Fix:** 
```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id  # or use ARM_SUBSCRIPTION_ID env var
}
```

**Line 2-7:** Missing Terraform version constraint
**Problem:** No required_version specified, can cause compatibility issues

**Fix:** Add at the top of terraform block:
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.50.0"  # More specific version
    }
  }
  # ... rest of config
}
```

**Line 9-14:** Backend configuration hardcoded
**Problem:** Backend config should be in separate config or use partial configuration

**Fix:** Move to `backend.hcl` or use `-backend-config` flags

---

## 2. variables.tf

### Critical Issues:

**All variables:** Missing types, descriptions, and validation

**Current State:**
```hcl
variable "location" {
  default = "Central India"
}
```

**Problems:**
- No type specified
- No description
- No validation
- Default value may not be appropriate for all environments

**Fix:**
```hcl
variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "Central India"
  
  validation {
    condition = contains([
      "Central India",
      "East US",
      "West US",
      # ... other valid regions
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
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
  sensitive   = false  # Path itself is not sensitive, but consider reading content
  
  validation {
    condition     = fileexists(var.ssh_public_key)
    error_message = "SSH public key file must exist."
  }
}
```

### Missing Variables:
- `subscription_id` (should be added)
- `resource_group_name` (optional, currently auto-generated)
- `vm_size_jenkins`
- `vm_size_sonar`
- `disk_size_jenkins`
- `disk_size_sonar`
- `allowed_source_addresses` (for NSG rules)
- `environment` (or use terraform.workspace)
- `tags` (common tags map)
- `vm_image_publisher`
- `vm_image_offer`
- `vm_image_sku`
- `vm_image_version`

---

## 3. network.tf

### Critical Security Issues:

**Lines 37-83:** NSG Rules allow traffic from "*" (0.0.0.0/0)

**Current State:**
```hcl
security_rule {
  source_address_prefix = "*"
}
```

**Problem:** 
- Exposes all services to entire internet
- Major security vulnerability
- No IP filtering

**Fix:**
```hcl
variable "allowed_source_addresses" {
  description = "List of IP addresses or CIDR blocks allowed to access resources"
  type        = list(string)
  default     = []
  
  validation {
    condition     = length(var.allowed_source_addresses) > 0
    error_message = "At least one source address must be specified for security."
  }
}

resource "azurerm_network_security_group" "nsg" {
  # ... existing config ...
  
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_source_addresses  # Changed to list
    destination_address_prefix = "*"
  }
  
  # Or use source_address_prefix for single IP:
  # source_address_prefix = length(var.allowed_source_addresses) > 0 ? var.allowed_source_addresses[0] : null
}
```

### Missing Features:

**Line 32:** No tags on NSG resource
**Fix:** Add tags block

**Line 12:** Hardcoded address space
**Fix:** Make it a variable

**Line 26:** Hardcoded subnet address prefix
**Fix:** Make it a variable

### Optimization:

**Missing:** NSG association should use subnet delegation instead of individual NIC associations (more efficient)

---

## 4. vm-jenkins.tf

### Issues:

**Line 31:** Hardcoded VM size
**Fix:** Use variable `var.vm_size_jenkins`

**Line 44:** Hardcoded disk size
**Fix:** Use variable `var.disk_size_jenkins`

**Line 47-52:** Hardcoded image reference
**Fix:** Use variables or data source for latest image

**Line 51:** Using "latest" version (not recommended)
**Fix:** Pin to specific version or use data source

**Line 43:** Using Standard_LRS (consider Premium_LRS for better performance)

**Missing:**
- Tags on all resources
- Managed identity
- Availability zone
- Lifecycle block
- Dependencies (VM should wait for script file to exist)

**Line 54:** Custom data file reference
**Fix:** Add validation that file exists

### Suggested Improvements:

```hcl
resource "azurerm_linux_virtual_machine" "jenkins_vm" {
  # ... existing config ...
  
  zone = var.enable_availability_zones ? 1 : null
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = local.common_tags
  
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      source_image_reference  # Prevent recreation on image updates
    ]
  }
}
```

---

## 5. vm-sonar-nexu.tf

### Issues:

**Filename:** Typo - should be `vm-sonar-nexus.tf` (currently `nexu`)

**All issues from vm-jenkins.tf apply here as well:**
- Hardcoded values
- Missing tags
- Missing managed identity
- Missing lifecycle blocks
- Using "latest" version

**Line 44:** Different disk size (80GB vs 60GB) - should use variable

**Additional Issue:**
- Running both SonarQube and Nexus on same VM without resource limits
- No persistence volumes for Docker containers (data loss risk)

---

## 6. outputs.tf

### Missing Outputs:

**Current:** Only outputs IP addresses

**Should Add:**
```hcl
output "jenkins_public_ip" {
  description = "Public IP address of Jenkins VM"
  value       = azurerm_public_ip.jenkins_public_ip.ip_address
}

output "jenkins_vm_id" {
  description = "Resource ID of Jenkins VM"
  value       = azurerm_linux_virtual_machine.jenkins_vm.id
}

output "jenkins_vm_name" {
  description = "Name of Jenkins VM"
  value       = azurerm_linux_virtual_machine.jenkins_vm.name
}

output "jenkins_url" {
  description = "Jenkins Web UI URL"
  value       = "http://${azurerm_public_ip.jenkins_public_ip.ip_address}:8080"
}

output "jenkins_ssh_command" {
  description = "SSH command to connect to Jenkins VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.jenkins_public_ip.ip_address}"
}

output "sonar_public_ip" {
  description = "Public IP address of SonarQube/Nexus VM"
  value       = azurerm_public_ip.sonar_public_ip.ip_address
}

output "sonar_url" {
  description = "SonarQube Web UI URL"
  value       = "http://${azurerm_public_ip.sonar_public_ip.ip_address}:9000"
}

output "nexus_url" {
  description = "Nexus Web UI URL"
  value       = "http://${azurerm_public_ip.sonar_public_ip.ip_address}:8081"
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.devops.name
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}
```

---

## 7. terraform.tfvars

### Issues:

**Line 3:** Hardcoded Windows absolute path
```hcl
ssh_public_key = "C:/Users/prash/.ssh/id_rsa.pub"
```

**Problems:**
- Not portable
- Username-specific
- Windows-specific path format

**Fix Options:**
1. Use relative path: `ssh_public_key = "~/.ssh/id_rsa.pub"` (if Terraform expands ~)
2. Use environment variable
3. Use `file()` function with relative path
4. Document required path format

**Missing:**
- `allowed_source_addresses` (critical for NSG)
- Other optional variables

---

## 8. main.tf

### Issue:

**File is completely empty** - Should either:
- Delete the file, OR
- Use it for common configuration (locals, data sources)

**Recommended Use:**
```hcl
locals {
  common_tags = {
    Environment = terraform.workspace
    Project     = "Azure DevOps Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = var.project_owner  # Add to variables
    CostCenter  = var.cost_center    # Add to variables
  }
  
  resource_prefix = "devops-${terraform.workspace}"
  
  # Common naming
  resource_group_name = "${local.resource_prefix}-rg"
  vnet_name           = "${local.resource_prefix}-vnet"
  subnet_name         = "${local.resource_prefix}-subnet"
  nsg_name            = "${local.resource_prefix}-nsg"
}

# Data sources
data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}
```

---

## 9. Missing Files/Configuration

### Should Create:

1. **README.md** - Documentation
2. **.gitignore** - Ignore terraform files
3. **versions.tf** - Separate version constraints (optional but cleaner)
4. **locals.tf** - Common values (alternative to main.tf)
5. **tags.tf** - Tagging strategy (alternative approach)
6. **backend.hcl.example** - Example backend config

### .gitignore should include:
```
.terraform/
.terraform.lock.hcl
*.tfstate
*.tfstate.*
*.tfvars
!terraform.tfvars.example
.terraformrc
terraform.rc
crash.log
crash.*.log
*.tfplan
```

---

## 10. Code Duplication Issues

### Problem:
`vm-jenkins.tf` and `vm-sonar-nexu.tf` have nearly identical structure:
- Public IP resource
- Network Interface resource
- NSG Association resource
- VM resource

### Solution Options:

**Option 1: Use for_each with locals**
```hcl
locals {
  vms = {
    jenkins = {
      size         = "Standard_B2ms"
      disk_size_gb = 60
      script       = "jenkins-install.sh"
    }
    sonar = {
      size         = "Standard_B2ms"
      disk_size_gb = 80
      script       = "sonar-nexus-install.sh"
    }
  }
}

resource "azurerm_public_ip" "vm_public_ip" {
  for_each            = local.vms
  name                = "${each.key}-${terraform.workspace}-public-ip"
  resource_group_name = azurerm_resource_group.devops.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
```

**Option 2: Create a module** (better for reusability)

---

## 11. Script Files Issues

### scripts/jenkins-install.sh
- Hardcoded username "azureuser" (should use variable)
- No error handling
- No logging
- No verification that services started

### scripts/sonar-nexus-install.sh
- Docker containers run without restart policy
- No volume persistence
- No resource limits
- No health checks
- Both services on same VM (resource contention)

---

## 12. Additional Recommendations

### High Priority:
1. ✅ Add tags to all resources
2. ✅ Restrict NSG source addresses
3. ✅ Remove hardcoded subscription ID
4. ✅ Add variable types and validation
5. ✅ Add managed identity to VMs
6. ✅ Fix filename typo

### Medium Priority:
1. Create module for VMs (reduce duplication)
2. Add more outputs
3. Pin image versions
4. Add lifecycle blocks
5. Add data sources

### Low Priority:
1. Add availability zones
2. Consider using Azure Container Instances instead of Docker on VMs
3. Add monitoring/alerting resources
4. Add backup configuration
5. Create separate subnets for different tiers

---

## Summary of Required Changes

### Security (Critical):
- [ ] Remove hardcoded subscription ID
- [ ] Restrict NSG source addresses from "*"
- [ ] Mark sensitive variables
- [ ] Add managed identity

### Code Quality (High):
- [ ] Add variable types and descriptions
- [ ] Add validation rules
- [ ] Add tags to all resources
- [ ] Fix filename typo
- [ ] Pin Terraform version
- [ ] Pin provider version more strictly

### Optimization (Medium):
- [ ] Create locals block
- [ ] Reduce code duplication (module or for_each)
- [ ] Add more outputs
- [ ] Pin image versions
- [ ] Add lifecycle blocks

### Documentation (Low):
- [ ] Add README.md
- [ ] Add .gitignore
- [ ] Document variables
- [ ] Add examples

