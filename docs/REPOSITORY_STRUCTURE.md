# Repository Structure Documentation

## Overview

This document provides a comprehensive overview of the repository structure, file organization, and best practices for maintaining this Terraform project.

## 📁 Directory Structure

```
terraform-azure-devops-infra/
│
├── 📄 Core Terraform Files
│   ├── main.tf                      # Data sources and locals
│   ├── variables.tf                 # Variable definitions with validation
│   ├── versions.tf                  # Version constraints
│   ├── providers.tf                 # Provider and backend configuration
│   ├── outputs.tf                   # Output values
│   │
│   ├── 📦 Resource Files
│   ├── network.tf                   # Network resources (VNet, Subnet, NSG)
│   ├── vm-jenkins.tf               # Jenkins VM resources
│   └── vm-sonar-nexus.tf           # SonarQube/Nexus VM resources
│
├── 📝 Configuration Files
│   ├── terraform.tfvars            # Variable values (gitignored)
│   ├── terraform.tfvars.example    # Example configuration
│   └── .gitignore                   # Git ignore patterns
│
├── 📚 Documentation
│   ├── README.md                    # Main documentation
│   └── docs/                        # Detailed documentation
│       ├── CHANGES.md              # Change log
│       ├── TERRAFORM_REVIEW.md     # Code review analysis
│       ├── DETAILED_ISSUES_AND_FIXES.md
│       ├── QUICK_SUMMARY.md        # Quick reference
│       ├── STRUCTURE_RECOMMENDATIONS.md
│       ├── STRUCTURE_IMPROVEMENTS.md
│       ├── UPGRADE_GUIDE.md        # Upgrade instructions
│       └── REPOSITORY_STRUCTURE.md # This file
│
└── 🔧 Scripts
    └── scripts/
        ├── jenkins-install.sh      # Jenkins installation script
        └── sonar-nexus-install.sh  # SonarQube/Nexus installation script
```

## 📄 File Descriptions

### Core Terraform Files

#### `main.tf`
- **Purpose**: Contains data sources and local values
- **Contents**:
  - Azure subscription data source
  - Azure client config data source
  - Local values for environment, naming, and tags
- **Dependencies**: None (root file)

#### `variables.tf`
- **Purpose**: Variable definitions with types, descriptions, and validation
- **Key Variables**:
  - `subscription_id`: Azure subscription ID (sensitive)
  - `location`: Azure region
  - `allowed_source_addresses`: NSG IP restrictions
  - VM configuration variables
  - Tagging variables
- **Best Practice**: All variables include validation rules

#### `versions.tf`
- **Purpose**: Terraform and provider version constraints
- **Contents**:
  - Terraform version requirement (>= 1.0)
  - Azure provider version (~> 4.50.0)
- **Why Separate**: Clean separation of version management

#### `providers.tf`
- **Purpose**: Provider configuration and backend
- **Contents**:
  - Azure provider configuration
  - Backend configuration (Azure Storage)
  - Provider features
- **Security**: No hardcoded credentials

#### `network.tf`
- **Purpose**: Network infrastructure resources
- **Resources**:
  - Resource Group
  - Virtual Network
  - Subnet
  - Network Security Group (with security rules)
- **Security**: Configurable NSG rules

#### `vm-jenkins.tf`
- **Purpose**: Jenkins VM infrastructure
- **Resources**:
  - Public IP
  - Network Interface
  - NSG Association
  - Linux Virtual Machine
- **Features**: Managed identity, tags, lifecycle blocks

#### `vm-sonar-nexus.tf`
- **Purpose**: SonarQube and Nexus VM infrastructure
- **Resources**: Same structure as Jenkins VM
- **Note**: Both services run on the same VM

#### `outputs.tf`
- **Purpose**: Output values for deployed resources
- **Outputs Include**:
  - Resource names and IDs
  - IP addresses (public and private)
  - Service URLs
  - SSH commands
  - Managed identity IDs
  - Summary object

### Configuration Files

#### `terraform.tfvars`
- **Purpose**: Actual variable values
- **Status**: Gitignored (contains sensitive data)
- **Format**: HCL (HashiCorp Configuration Language)

#### `terraform.tfvars.example`
- **Purpose**: Example configuration template
- **Usage**: Copy to `terraform.tfvars` and customize
- **Status**: Committed to repository

#### `.gitignore`
- **Purpose**: Git ignore patterns
- **Ignores**:
  - `.terraform/` directories
  - `*.tfstate` files
  - `*.tfvars` files (except examples)
  - Plan files, logs, backups

### Documentation

#### `README.md`
- **Purpose**: Main project documentation
- **Sections**:
  - Architecture overview
  - Prerequisites
  - Quick start guide
  - Configuration options
  - Security best practices
  - Troubleshooting

#### `docs/` Folder
- **Purpose**: Detailed documentation
- **Files**:
  - Review documents
  - Change logs
  - Upgrade guides
  - Structure recommendations

### Scripts

#### `scripts/jenkins-install.sh`
- **Purpose**: Cloud-init script for Jenkins installation
- **Execution**: Runs automatically on VM boot
- **Actions**:
  - Updates packages
  - Installs Java and Docker
  - Installs and starts Jenkins

#### `scripts/sonar-nexus-install.sh`
- **Purpose**: Cloud-init script for SonarQube/Nexus installation
- **Execution**: Runs automatically on VM boot
- **Actions**:
  - Updates packages
  - Installs Docker
  - Runs SonarQube and Nexus containers

## 🏗️ Architecture Patterns

### Naming Convention

All resources follow a consistent naming pattern:
```
{service}-{environment}-{resource-type}
```

**Examples**:
- `devops-dev-rg` (Resource Group)
- `jenkins-dev-public-ip` (Public IP)
- `devops-prod-nsg` (Network Security Group)

### Tagging Strategy

All resources include standard tags:
- `Environment`: Environment name (dev, staging, prod)
- `Project`: Project name
- `ManagedBy`: Always "Terraform"
- `Owner`: Project owner
- `CostCenter`: Cost center for billing
- `CreatedDate`: Creation date

### Resource Organization

- **Network**: Separate file for networking resources
- **Compute**: Separate files per VM/service
- **Common**: Shared configuration in `main.tf`
- **Config**: Variables and outputs in dedicated files

## 🔄 Workflow Patterns

### Development Workflow

1. **Plan Changes**
   ```bash
   terraform plan
   ```

2. **Review Changes**
   - Check what will be created/modified/destroyed
   - Verify variable values

3. **Apply Changes**
   ```bash
   terraform apply
   ```

4. **Verify Deployment**
   ```bash
   terraform output
   ```

### Environment Management

Uses Terraform workspaces:
```bash
# Create workspace
terraform workspace new dev

# Select workspace
terraform workspace select dev

# List workspaces
terraform workspace list
```

## 📦 Module Considerations

### Current Structure
- **Flat structure**: All resources in root module
- **Appropriate for**: Small to medium projects (2-5 VMs)

### Future Modular Structure
Consider modules when:
- Adding 5+ VMs
- Reusing configurations across projects
- Managing multiple environments with different configs

**Potential Modules**:
- `modules/network/` - Network resources
- `modules/linux-vm/` - Reusable VM module
- `modules/security/` - Security group rules

## 🔒 Security Best Practices

### File Organization
- ✅ Sensitive files in `.gitignore`
- ✅ Example files committed for reference
- ✅ No hardcoded credentials
- ✅ Variables marked as sensitive

### State Management
- ✅ Remote backend (Azure Storage)
- ✅ State file encryption
- ✅ State locking enabled

### Access Control
- ✅ NSG rules configurable
- ✅ Managed identities for service authentication
- ✅ SSH key authentication

## 📊 Metrics and Monitoring

### Cost Tracking
- Resource tagging enables cost analysis
- All resources tagged with CostCenter
- Environment tags for cost separation

### Resource Visibility
- Comprehensive outputs for monitoring
- Resource IDs for Azure Monitor integration
- Service URLs for health checks

## 🛠️ Maintenance Guidelines

### Adding New Resources
1. Add resource to appropriate file (or create new file)
2. Add corresponding variables to `variables.tf`
3. Add outputs to `outputs.tf`
4. Update `terraform.tfvars.example`
5. Update documentation

### Updating Existing Resources
1. Modify resource definition
2. Run `terraform plan` to review changes
3. Test in development environment
4. Apply to production

### Version Management
- Update `versions.tf` when upgrading Terraform/provider
- Test version upgrades in development first
- Document breaking changes

## 🎯 Best Practices Summary

1. ✅ **Consistent Naming**: Use naming conventions
2. ✅ **Resource Tagging**: Tag all resources
3. ✅ **Variable Validation**: Validate all inputs
4. ✅ **Documentation**: Keep docs updated
5. ✅ **Version Control**: Pin versions appropriately
6. ✅ **Security**: No hardcoded secrets
7. ✅ **State Management**: Use remote backend
8. ✅ **Testing**: Test changes before production

## 📚 Additional Resources

- **Terraform Docs**: https://www.terraform.io/docs
- **Azure Provider**: https://registry.terraform.io/providers/hashicorp/azurerm
- **Best Practices**: See `docs/STRUCTURE_RECOMMENDATIONS.md`

---

**Last Updated**: 2025-01-12
**Maintained By**: DevOps Team

