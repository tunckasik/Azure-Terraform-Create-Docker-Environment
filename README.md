# Azure-Terraform-Create-Docker-Environment

This repository contains a Terraform configuration file that deploys a Docker environment in Azure. The configuration file provisions a virtual machine along with other required resources such as a resource group, virtual network, subnet, public IP address, and user assigned identity. Additionally, the configuration file includes a custom script, **customdata.sh**, that installs Docker and Docker Compose on the Ubuntu virtual machine.
 
### Prerequisites
Before running this configuration file, make sure you have the following:

 - Azure account
 - Terraform installed
 - SSH key pair generated (public key added to your Azure account)
 
### Usage
1. Clone this repository: 
```
git clone https://github.com/tunckasik/Azure-Terraform-Create-Docker-Environment.git
```
1. Change into the directory: 
```
cd Azure-Terraform-Create-Docker-Environment
```
1. Change the variables.tf file with the following variables:

```hcl
prefix          = "<your-prefix>"
location        = "<azure-region>"
admin_username  = "clouduser"
ssh_key_rg      = "<ssh-key-resource-group>"
ssh_key_name    = "<ssh-key-name>"
ssh_private_key_path = "/ssh-private-key-path"
```
### Clean up
To delete all resources created by this configuration file, run the following command:

```hcl
terraform destroy
```
> *Note*
The customdata.sh script is executed during the virtual machine provisioning process. You can modify this script to install additional software or perform other configuration tasks.
