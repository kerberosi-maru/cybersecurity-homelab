#!/bin/bash
# Homelab aliases for Jumpbox (Ubuntu)
# Source this file or add to ~/.bashrc

alias remnux='ssh remnux@192.168.60.100'
alias fileserver='python3 -m http.server 8000'
alias sandbox-capture='sudo tcpdump -i any -w /tmp/sandbox_capture.pcap'
alias sandbox-status='echo "=== SANDBOX Connectivity Check ===" && ping -c 2 192.168.60.100 && ping -c 2 192.168.60.101'
