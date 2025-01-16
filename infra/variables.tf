variable "rgName" {
  description = "The name of the ResourceGroup Created in Ansible"
  type        = string
  default     = "ansibleDemo"
}

variable "vm_subnet_name" {
  description = "The name of the VM subnet"
  type        = string
  default     = "VMSubnet"
}

