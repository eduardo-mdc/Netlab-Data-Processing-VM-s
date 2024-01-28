
#!/bin/bash
# Define network XML configuration
cat > ubuntuVMnetwork.xml <<EOF
<network>
  <name>ubuntuVMnetwork</name>
  <bridge name="virbr2" stp="on" delay="0"/>
  <mac address="52:54:00:78:04:82"/>
  <ip address="192.168.100.1" netmask="255.255.255.0">
    <dhcp>
      <range start="192.168.100.50" end="192.168.100.200"/>
    </dhcp>
  </ip>
</network>
EOF

# Define the network
virsh net-define ubuntuVMnetwork.xml

# Start the network
virsh net-start ubuntuVMnetwork

# Set the network to autostart
virsh net-autostart ubuntuVMnetwork

# Confirm the network is set up
echo "Network 'ubuntuVMnetwork' has been set up and started."