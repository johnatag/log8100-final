resource "proxmox_vm_qemu" "proxmox_vm_master" {
    
    count = var.num_k3s_masters

    # VM General Settings
    target_node = var.pm_node_name
    name = "k3s-master-${count.index}"
    desc = "k3s master node"

    # VM OS Settings
    clone = var.template_vm_name

    # VM System Settings
    agent = 1

    # VM CPU Settings
    cores = 4
    sockets = 1
    cpu = "host"

    # VM Memory Settings
    memory = var.num_k3s_masters_mem
    
    network {
      bridge = "vmbr0"
      model = "virtio"
    }

    # VM Cloud-Init Settings
    os_type = "cloud-init"

    # IP Address and Gateway
    ipconfig0 = "ip=${var.master_ips[count.index]}/${var.networkrange},gw=${var.gateway}"
    ciuser = "k3suser"

    # SSH KEY
    sshkeys = <<EOF
    ${var.ssh_public_key}
    EOF

}

resource "proxmox_vm_qemu" "proxmox_vm_workers" {
    count = var.num_k3s_nodes

    # VM General Settings
    target_node = var.pm_node_name
    name = "k3s-worker-${count.index}"
    desc = "k3s worker node"
    
    # VM OS Settings
    clone = var.template_vm_name

    # VM System Settings
    agent = 1

    # VM CPU Settings
    cores = 2

    # VM Memory Settings
    memory = var.num_k3s_nodes_mem

    # VM Cloud-Init Settings
    os_type = "cloud-init"

    # IP Address and Gateway
    ipconfig0 = "ip=${var.worker_ips[count.index]}/${var.networkrange},gw=${var.gateway}"
    ciuser = "k3suser"

    sshkeys = <<EOF
    ${var.ssh_public_key}
    EOF
}

data "template_file" "k8s" {
  template = file("./templates/k8s.tpl")
  vars = {
    k3s_master_ip = "${join("\n", [for instance in proxmox_vm_qemu.proxmox_vm_master : join("", [instance.default_ipv4_address, " ansible_ssh_private_key_file=", var.ssh_private_key])])}"
    k3s_node_ip   = "${join("\n", [for instance in proxmox_vm_qemu.proxmox_vm_workers : join("", [instance.default_ipv4_address, " ansible_ssh_private_key_file=", var.ssh_private_key])])}"
  }
}

resource "local_file" "k8s_file" {
  content  = data.template_file.k8s.rendered
  filename = "../ansible/inventory/my-cluster/hosts.ini"
}

resource "local_file" "var_file" {
  source   = "../ansible/inventory/sample/group_vars/all.yml"
  filename = "../ansible/inventory/my-cluster/group_vars/all.yml"
}