variable "prefix" {
  default = "docker"
}

variable "location" {
  default = "eastus"
}

variable "admin_username" {
  default = "clouduser"
}

variable "ssh_key_rg" {
  default = "tf-state-rg"
}

variable "ssh_key_name" {
  default = "tf-state-key"
}

variable "ssh_private_key_path" {
  default = "~/.ssh/"
}