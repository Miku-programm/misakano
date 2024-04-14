#!/bin/bash
# Open the sysctl configuration file in vim
vim /etc/sysctl.conf

# Add the following lines to the file to disable IPv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf

# Apply the changes
sudo sysctl -p
