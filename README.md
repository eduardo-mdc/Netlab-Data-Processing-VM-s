# Table of Contents

    1. Overview
    2. Prerequisites
    3. Installing Infrastructure Software
    4. Creating the Virtual Network
    5. Enabling Packet Forwarding
    6. Creating and Configuring VMs with Terraform
    7. Verifying Network and Machine Status
    8. Running Ansible Playbook for VM Configuration
    9. Additional Notes
    10. Troubleshooting

# 1. Overview

This project establishes a set of Data Processing VMs within an environment, enabling streamlined data analysis and manipulation. By utilizing Terraform and Ansible, we facilitate automated infrastructure provisioning and configuration.

# 2. Prerequisites
    - Host machine with Ansible, Terraform, and SSH client installed.
    - Virtualization platform, in this case, libvirt

# 2.1 Installing Ansible Modules

```bash
ansible-galaxy collection install community.mysql
```

# 3. Installing Infrastructure Software
 
## 3.1. Ansible on Your PC

Windows: Download and install from https://www.terraform.io/downloads.html

Linux/macOS: Use package manager:

```bash
sudo apt-get install ansible  # Debian/Ubuntu
sudo yum install ansible    # CentOS/RHEL
brew install ansible        # macOS
```

## 3.2. Terraform on Processing Host

Windows: Download and install the Terraform CLI from https://www.terraform.io/downloads.html.

Linux/macOS: Use package manager or download tarball from https://www.terraform.io/downloads.html.

# 4. Creating the Virtual Network

## 4.1. Script Preparation

    Ensure virtual_network.sh has executable permissions:

```bash
cd scripts
chmod +x scripts/virtual_network.sh
```

## 4.2. Network Creation

Run the script:
```bash
sudo ./scripts/virtual_network.sh
```

This script automatically creates and configures the virtual network using commands specific to your chosen virtualization platform. You'll need to provide credentials and during execution.

# 5. Enabling Packet Forwarding

Execute the following on the processing host to enable internet access for VMs:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

# 6. Creating and Configuring VMs with Terraform

## 6.1. Navigation:

```bash
cd terraform
```

### 6.2. Infrastructure Provisioning:

```bash
terraform apply
```

This action deploys the VMs and network infrastructure based on the configurations defined in `main.tf`.

# 7. Verifying Network and Machine Status

## 7.1. Network Scan:

Check VM reachability:

```bash
nmap -sn 192.168.100.0/24
```

## 7.2. Individual VM Checks:

Use SSH to connect to each VM and verify its basic functions.

```bash
cd terraform 
ssh -i ssh_keys/workstations/id_rsa0 root@192.168.100.10
# Continue for each one
```

# 8. Running Ansible Playbook for VM Configuration

## 8.0 Allow root access through SSH

```bash
ssh <user>@machine
sudo nano /etc/ssh/sshd_config
PermitRootLogin yes
```

## 8.1. Configuration Execution:

Run the playbook to configure installed software (e.g., MySQL):

```bash
ansible-playbook install_mysql.yaml -i iventory -vv -K
ansible-playbook create_databases.yaml -i iventory -vv -K
```

# 9. Additional Notes

    Replace placeholders in scripts and configurations with your specific parameters.
    Modify playbooks to perform different configuration tasks on VMs.
    Refer to the official documentation for Ansible and Terraform for advanced usage.

# 10. Troubleshooting

    Consult logs and error messages for specific issues.
    Refer to online resources and forums for community support.
