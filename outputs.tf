# Network outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.network.resource_group_name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = var.location
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = module.network.virtual_network_name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = module.network.subnet_name
}

output "network_security_group_name" {
  description = "Name of the network security group"
  value       = module.network.network_security_group_name
}

# Jenkins outputs
output "jenkins_vm_name" {
  description = "Name of the Jenkins virtual machine"
  value       = module.jenkins_vm.vm_name
}

output "jenkins_vm_id" {
  description = "Resource ID of the Jenkins virtual machine"
  value       = module.jenkins_vm.vm_id
}

output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins virtual machine"
  value       = module.jenkins_vm.vm_public_ip
}

output "jenkins_private_ip" {
  description = "Private IP address of the Jenkins virtual machine"
  value       = module.jenkins_vm.vm_private_ip
}

output "jenkins_url" {
  description = "Jenkins Web UI URL"
  value       = "http://${module.jenkins_vm.vm_public_ip}:8080"
}

output "jenkins_ssh_command" {
  description = "SSH command to connect to Jenkins virtual machine"
  value       = "ssh ${var.admin_username}@${module.jenkins_vm.vm_public_ip}"
}

output "jenkins_managed_identity_principal_id" {
  description = "Principal ID of the Jenkins VM's managed identity"
  value       = module.jenkins_vm.managed_identity_principal_id
}

# SonarQube/Nexus outputs
output "sonar_vm_name" {
  description = "Name of the SonarQube/Nexus virtual machine"
  value       = module.sonar_vm.vm_name
}

output "sonar_vm_id" {
  description = "Resource ID of the SonarQube/Nexus virtual machine"
  value       = module.sonar_vm.vm_id
}

output "sonar_public_ip" {
  description = "Public IP address of the SonarQube/Nexus virtual machine"
  value       = module.sonar_vm.vm_public_ip
}

output "sonar_private_ip" {
  description = "Private IP address of the SonarQube/Nexus virtual machine"
  value       = module.sonar_vm.vm_private_ip
}

output "sonarqube_url" {
  description = "SonarQube Web UI URL"
  value       = "http://${module.sonar_vm.vm_public_ip}:9000"
}

output "nexus_url" {
  description = "Nexus Repository Web UI URL"
  value       = "http://${module.sonar_vm.vm_public_ip}:8081"
}

output "sonar_ssh_command" {
  description = "SSH command to connect to SonarQube/Nexus virtual machine"
  value       = "ssh ${var.admin_username}@${module.sonar_vm.vm_public_ip}"
}

output "sonar_managed_identity_principal_id" {
  description = "Principal ID of the SonarQube/Nexus VM's managed identity"
  value       = module.sonar_vm.managed_identity_principal_id
}

# Summary output
output "summary" {
  description = "Summary of deployed resources"
  value = {
    environment        = local.environment
    resource_group     = module.network.resource_group_name
    jenkins_url        = "http://${module.jenkins_vm.vm_public_ip}:8080"
    sonarqube_url      = "http://${module.sonar_vm.vm_public_ip}:9000"
    nexus_url          = "http://${module.sonar_vm.vm_public_ip}:8081"
    jenkins_public_ip  = module.jenkins_vm.vm_public_ip
    sonar_public_ip    = module.sonar_vm.vm_public_ip
  }
}
