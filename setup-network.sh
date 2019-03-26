#!/bin/bash

# Set -e so that if any command fails the script will exit immediately.
set -e

# Install packages

apt-get -y install dnsmasq hostapd tcpdump

# Configure

cp ${PWD}/etc/dhcpcd.conf /etc/dhcpcd.conf
cp ${PWD}/etc/dnsmasq.conf /etc/dnsmasq.conf
cp ${PWD}/etc/hostapd.conf /etc/hostapd/hostapd.conf
cp ${PWD}/etc/sysctl.conf /etc/sysctl.conf
cp ${PWD}/default/hostapd /etc/default/hostapd
cp ${PWD}/etc/network/interfaces /etc/network/interfaces
cp ${PWD}/etc/rc.local /etc/rc.local

# Enable services
systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq

# Setup iptables
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT  
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

iptables-save > /etc/iptables.up.rules

echo "Please reboot to finish configuring the network."
