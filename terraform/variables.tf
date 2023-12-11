variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
    sensitive = true
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "pm_tls_insecure" {
  description = "Set to true to ignore certificate errors"
  type        = bool
  default     = false
}

variable "pm_node_name" {
  description = "name of the proxmox node to create the VMs on"
  type        = string
  default     = "pve"
}

variable "ssh_private_key" {}
variable "ssh_public_key" {}

variable "num_k3s_masters" {
  default = 1
}

variable "num_k3s_masters_mem" {
  default = 4096
}

variable "num_k3s_nodes" {
  default = 1
}

variable "num_k3s_nodes_mem" {
  default = 4096
}

variable "template_vm_name" {
  default = "ubuntu-server-jammy"
}

variable "master_ips" {
  description = "List of ip addresses for master nodes"
}

variable "worker_ips" {
  description = "List of ip addresses for worker nodes"
}

variable "networkrange" {
  default = 24
}

variable "gateway" {
  default = "192.168.2.1"
}