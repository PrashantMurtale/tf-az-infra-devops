# Azure DevOps Infrastructure - Terraform

This Terraform project deploys a production-ready Azure infrastructure for DevOps tools including Jenkins, SonarQube, and Nexus Repository.

## Architecture

The infrastructure includes:
- **Resource Group**: Centralized resource management
- **Virtual Network**: Isolated network environment with subnet
- **Network Security Group**: Security rules for SSH and application ports
- **Jenkins VM**: Continuous Integration/Continuous Deployment server
- **SonarQube/Nexus VM**: Code quality analysis and artifact repository

## Prerequisites

1. **Azure CLI** installed and configured
   ```bash
   az login
   az account set --subscription <subscription-id>
   ```

2. **Terraform** >= 1.0 installed
   - Download from [terraform.io](https://www.terraform.io/downloads)
   - Verify: `terraform version`

3. **SSH Key Pair** generated
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

4. **Azure Subscription** with appropriate permissions
   - Contributor role or equivalent

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd terraform-azure-devops-infra
   ```

2. **Configure variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Review the execution plan**
   ```bash
   terraform plan
   ```

5. **Deploy the infrastructure**
   ```bash
   terraform apply
   ```

6. **Access the services**
   After deployment, access:
   - **Jenkins**: `http://<jenkins-public-ip>:8080`
   - **SonarQube**: `http://<sonar-public-ip>:9000`
   - **Nexus**: `http://<sonar-public-ip>:8081`

   Get the IPs from: `terraform output`

## Configuration

### Required Variables

- `location`: Azure region (e.g., "Central India", "East US")
- `ssh_public_key`: Path to your SSH public key file
- `admin_username`: Administrator username for VMs

### Important Security Settings

⚠️ **CRITICAL**: Before deploying to production, update `allowed_source_addresses` in `terraform.tfvars`:

```hcl
# Production example - restrict to specific IPs
allowed_source_addresses = ["203.0.113.0/24", "198.51.100.50"]

# Development/Testing only (NOT for production)
allowed_source_addresses = ["*"]
```

### Workspace Support

The project uses Terraform workspaces for environment management:

```bash
# Create and switch to dev workspace
terraform workspace new dev
terraform workspace select dev

# Create and switch to prod workspace
terraform workspace new prod
terraform workspace select prod
```

### Subscription Configuration

Option 1: Use environment variable
```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
```

Option 2: Set in terraform.tfvars
```hcl
subscription_id = "your-subscription-id"
```

Option 3: Use default subscription from Azure CLI
```bash
az account set --subscription <subscription-id>
```

## Project Structure

```
terraform-azure-devops-infra/
├── main.tf                      # Root module - calls network and VM modules
├── variables.tf                 # Root variable definitions
├── versions.tf                  # Version constraints
├── providers.tf                 # Provider and backend configuration
├── outputs.tf                   # Root output values
├── terraform.tfvars            # Variable values (not committed)
├── terraform.tfvars.example    # Example variable values
├── .gitignore                   # Git ignore patterns
├── modules/                     # Reusable modules
│   ├── network/                 # Network module
│   │   ├── main.tf             # Network resources (RG, VNet, Subnet, NSG)
│   │   ├── variables.tf        # Network module variables
│   │   ├── outputs.tf          # Network module outputs
│   │   └── README.md           # Network module documentation
│   └── linux-vm/               # Linux VM module (reusable)
│       ├── main.tf             # VM resources (Public IP, NIC, VM)
│       ├── variables.tf        # VM module variables
│       ├── outputs.tf          # VM module outputs
│       └── README.md           # VM module documentation
├── scripts/                     # Cloud-init installation scripts
│   ├── jenkins-install.sh      # Jenkins installation script
│   └── sonar-nexus-install.sh  # SonarQube/Nexus installation script
├── docs/                        # Documentation and review files
│   ├── CHANGES.md              # Change log
│   ├── TERRAFORM_REVIEW.md     # Code review analysis
│   ├── DETAILED_ISSUES_AND_FIXES.md  # Detailed issues documentation
│   ├── QUICK_SUMMARY.md        # Quick reference summary
│   ├── STRUCTURE_RECOMMENDATIONS.md  # Structure recommendations
│   ├── UPGRADE_GUIDE.md        # Upgrade and migration guide
│   ├── REPOSITORY_STRUCTURE.md # Repository structure documentation
│   └── STRUCTURE_IMPROVEMENTS.md  # Structure improvements summary
└── README.md                    # This file
```

### Module Architecture

The repository uses a **modular structure** following Terraform best practices:

- **Root Module** (`main.tf`): Orchestrates the deployment by calling modules
- **Network Module** (`modules/network/`): Creates all networking resources
- **Linux VM Module** (`modules/linux-vm/`): Reusable module for creating Linux VMs

This structure provides:
- ✅ **DRY Principle**: No code duplication
- ✅ **Reusability**: Easy to add more VMs
- ✅ **Maintainability**: Centralized configuration
- ✅ **Scalability**: Easy to scale and extend

## Outputs

After deployment, use `terraform output` to view:

- Resource group and network information
- VM names and IDs
- Public and private IP addresses
- Service URLs (Jenkins, SonarQube, Nexus)
- SSH connection commands
- Managed identity principal IDs

## Security Best Practices

1. **Restrict NSG Source Addresses**: Never use `["*"]` in production
2. **Use Managed Identity**: VMs have system-assigned managed identities enabled
3. **Tag Resources**: All resources are tagged for cost tracking and management
4. **Secure State**: Terraform state is stored in Azure Storage with backend configuration
5. **SSH Key Management**: Use SSH keys instead of passwords

## Cost Considerations

- **VM Sizes**: Default is `Standard_B2ms` (2 vCPUs, 8GB RAM)
- **Storage**: Standard_LRS disks (can be upgraded to Premium_LRS for better performance)
- **Public IPs**: Static Standard SKU public IPs
- **Tags**: All resources are tagged for cost tracking

Estimated monthly cost (approximate):
- Jenkins VM: ~$60-80/month
- SonarQube/Nexus VM: ~$60-80/month
- Networking: ~$5-10/month
- **Total**: ~$125-170/month (varies by region)

## Troubleshooting

### SSH Connection Issues
```bash
# Get the SSH command from outputs
terraform output jenkins_ssh_command

# Or manually:
ssh azureuser@<public-ip>
```

### Service Not Accessible
1. Check NSG rules: Ensure your IP is in `allowed_source_addresses`
2. Check VM status: `az vm show -g <rg-name> -n <vm-name> --show-details`
3. Check service logs on VM: `sudo journalctl -u jenkins` or check Docker containers

### Terraform Backend Issues
If backend configuration fails, you can use local state temporarily:
```bash
# Comment out backend block in providers.tf
terraform init -migrate-state
```

## Maintenance

### Updating Infrastructure
```bash
terraform plan  # Review changes
terraform apply # Apply changes
```

### Destroying Infrastructure
```bash
terraform destroy
```

⚠️ **Warning**: This will delete all resources. Ensure you have backups if needed.

## Contributing

1. Follow Terraform best practices
2. Update documentation for any changes
3. Test changes in a development workspace first
4. Ensure all resources have proper tags

## License

This project is provided as-is for educational and development purposes.

## Documentation

Additional documentation is available in the `docs/` folder:
- **CHANGES.md**: Complete changelog of improvements made
- **TERRAFORM_REVIEW.md**: Comprehensive code review analysis
- **DETAILED_ISSUES_AND_FIXES.md**: Detailed file-by-file issues and fixes
- **QUICK_SUMMARY.md**: Quick reference summary
- **STRUCTURE_RECOMMENDATIONS.md**: Repository structure recommendations

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review documentation in the `docs/` folder
3. Review Azure documentation
4. Check Terraform Azure provider documentation

---

**Last Updated**: $(date)
**Terraform Version**: >= 1.0
**Azure Provider Version**: ~> 4.50.0

