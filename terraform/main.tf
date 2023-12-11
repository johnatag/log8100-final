resource "proxmox_vm_qemu" "proxmox_vm_master" {
  
    count = var.num_k3s_masters

    # VM General Settings
    target_node = "pve"
    name = "master-${count.index}"
    desc = "k3s master node"

    # VM OS Settings
    clone = var.template_vm_name

    # VM System Settings
    agent = "1"

    # VM CPU Settings
    cores = "2"
    sockets = "1"
    cpu = "host"

    # VM Memory Settings
    memory = "${var.num_k3s_masters_mem}"

    network {
      bridge = "vmbr0"
      model = "virtio"
    }

    disk {
      storage = "Storage"
      type = "virtio"
      size = "32G"
    }

    # VM Cloud-Init Settings
    #os_type = "cloud-init"

    # (Optional) IP Address and Gateway
    ipconfig0 = "ip=${var.master_ips[count.index]}/${var.networkrange},gw=${var.gateway}"
    nameserver = "${var.gateway}"
    ciuser = "user"

    # (Optional) Add your SSH KEY
    sshkeys = <<EOF
    ${var.ssh_public_key}
    EOF
}


