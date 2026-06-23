#!/bin/bash
# Bennett's Homelab Aliases & Functions
# Source this file on your Jumpbox: source /path/to/scripts/aliases.sh

# Quick SSH / mosh helpers
alias jump='mosh benne@192.168.10.50'          # Adjust username as needed
alias remnux='ssh remnux@192.168.60.100'

# Start simple Python upload server on REMnux (run via SSH or on REMnux directly)
alias fileserver='python3 -m http.server 8000 --directory /home/remnux/samples'

# Quick status check for the sandbox network
alias sandbox-status='bash ~/cybersecurity-homelab/scripts/sandbox-status.sh'

# Start packet capture for sandbox traffic (run on Jumpbox or pfSense if accessible)
alias sandbox-capture='sudo tcpdump -i any -w /tmp/sandbox_capture.pcap host 192.168.60.0/24'

echo "✅ Bennett's Homelab aliases loaded. Try: sandbox-status"
