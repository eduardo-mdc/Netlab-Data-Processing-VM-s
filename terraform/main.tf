terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Ubuntu Server Image

resource "libvirt_volume" "ubuntu-qcow2" {
  name   = "ubuntu.qcow2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/releases/22.04/release-20240126/ubuntu-22.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

# --- SSH Key Generation ---
resource "tls_private_key" "local_keys" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "public_key" {
  content     = tls_private_key.local_keys.public_key_openssh
  filename    = "${path.module}/ssh_keys/id_rsa.pub"
  file_permission = "0644"
}

resource "local_file" "private_key" {
  content     = tls_private_key.local_keys.private_key_pem
  filename    = "${path.module}/ssh_keys/id_rsa"
  file_permission = "0600"
}

# ----------------------------------------------------------------



resource "libvirt_volume" "vm-disk" {
  count  = 6
  name   = "ubuntu-vm-disk-${count.index}.qcow2"
  pool   = "default"
  format = "qcow2"
  base_volume_id = libvirt_volume.ubuntu-qcow2.id
}

resource "libvirt_volume" "postgres-vm-disk" {
  name   = "postgres-vm-disk.qcow2"
  pool   = "default"
  format = "qcow2"
  base_volume_id = libvirt_volume.ubuntu-qcow2.id
}

resource "libvirt_domain" "vm" {
  count  = 6
  name   = "ubuntu-vm-${count.index}"
  memory = "1024"
  vcpu   = 1

  network_interface {
    network_name = "ubuntuVMnetwork"
  }

  disk {
    volume_id = libvirt_volume.vm-disk[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id
}

resource "libvirt_domain" "postgres-vm" {
  name   = "postgres-ubuntu-vm"
  memory = "1024"
  vcpu   = 1

  network_interface {
    network_name = "ubuntuVMnetwork"
  }

  disk {
    volume_id = libvirt_volume.postgres-vm-disk.id
  }

  cloudinit = libvirt_cloudinit_disk.postgresinit.id
}



resource "libvirt_cloudinit_disk" "commoninit" {
  count = 6
  name  = "commoninit-${count.index}.iso"
  pool  = "default"
  user_data = <<-EOF
              #cloud-config
              password: ubuntu
              chpasswd: { expire: False }
              ssh_pwauth: True
              ssh_authorized_keys:
                - "${tls_private_key.local_keys.public_key_openssh}"
              EOF
}

resource "libvirt_cloudinit_disk" "postgresinit" {
  name    = "postgres-vm-cloudinit.iso"
  pool    = "default"
  user_data = <<-EOF
              #cloud-config
              password: postgres
              chpasswd: { expire: False }
              ssh_pwauth: True
              ssh_authorized_keys:
                - "${tls_private_key.local_keys.public_key_openssh}"
              EOF
}



output "ips" {
  value = libvirt_domain.vm.*.network_interface.0.addresses
}

