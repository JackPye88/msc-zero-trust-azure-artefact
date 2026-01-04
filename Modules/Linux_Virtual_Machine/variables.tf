# Input variable definitions

variable "vm_name" {
  description = "Name of the Location."
  type        = string
}

variable "location" {
  description = "Name of the Location."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group."
  type        = string
}
variable "des_name" {
  description = "Name of the Resource Group."
  type        = string
}
variable "des_rg" {
  description = "Name of the Resource Group."
  type        = string
}
variable "root_id" {
  description = "Name of the Resource Group."
  type        = string
}

variable "private_ip_address" {
  type = string
}
variable "subnetname" {
  type = string
}
variable "virtual_network_name" {
  type = string
}
variable "snet_resource_group_name" {
  type = string
}
variable "sku" {
  type = string
}
variable "bastion_ip" {
  type = string
}
variable "tags" {
  description = "tags to apply."
  type        = map(string)
  default     = {}
}

variable "server_os" {
  type = string

}

variable "data_disks" {
  description = "List of data disks with storage account type and size configurations."
  type = list(object({
    name                 = string
    size                 = number
    storage_account_type = string
  }))
  default = []
}