# Netlab Data Processing VM's

## Prerequisites

### Install Ansible on Your PC

### Install Terraform on Processing Host

### Create the virtual network 

```bash
cd scripts
chmod +x virtual_network.sh
sudo ./create_virtual_network.sh
```

### Enable Packet Fowarding for Internet Access

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

## Create and Configure Vm's 

### Run Terraform

```bash
cd terraform
terraform apply
```

### Verify the network and Machine Status

```bash 
nmap -sn 192.168.100.0/24
```

### Run Ansible Playbook for VM configuration

```bash
cd ansible
ansible-playbook install_mysql.yml
```