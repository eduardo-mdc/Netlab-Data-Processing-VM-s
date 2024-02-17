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
  source = "/home/eduardo-mdc/Downloads/ubuntu-22.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "tls_private_key" "workstation_keys" {
  count     = 6
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "local_file" "workstation_public_keys" {
  count          = 6
  content        = tls_private_key.workstation_keys[count.index].public_key_openssh
  filename       = "${path.module}/ssh_keys/workstations/id_rsa${count.index}.pub"
  file_permission = "0644"
}

resource "local_file" "workstation_private_keys" {
  count          = 6
  content        = tls_private_key.workstation_keys[count.index].private_key_pem
  filename       = "${path.module}/ssh_keys/workstations/id_rsa${count.index}"
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

resource "libvirt_domain" "vm" {
  count  = 6
  name   = "ubuntu-workstation${count.index}"
  memory = "4096"
  vcpu   = 2

  network_interface {
    network_name = "ubuntuVMnetwork"
  }

  disk {
    volume_id = libvirt_volume.vm-disk[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = 6
  name  = "commoninit-${count.index}.iso"
  pool  = "default"
  user_data = <<-EOF
              #cloud-config
              hostname: ubuntu-workstation${count.index}
              fqdn: ubuntu-workstation${count.index}.example.com
              users:
                - name: root
                  ssh-authorized-keys:
                    - "${tls_private_key.workstation_keys[count.index].public_key_openssh}"
                  sudo: ['ALL=(ALL) NOPASSWD:ALL']
                  shell: /bin/bash
              write_files:
                - path: /etc/netplan/01-netcfg.yaml
                  content: |
                    network:
                      version: 2
                      renderer: networkd
                      ethernets:
                        ens3:
                          dhcp4: no
                          dhcp6: no
                          addresses:
                            - 192.168.100.1${count.index}/24
                          gateway4: 192.168.100.1
                          nameservers:
                            addresses: [8.8.8.8, 8.8.4.4]
              runcmd:
                - netplan apply
              EOF
}