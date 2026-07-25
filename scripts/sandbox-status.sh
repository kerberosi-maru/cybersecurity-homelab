#!/bin/bash
# Quick connectivity check for the malware analysis sandbox

echo "=== SANDBOX Connectivity Check ==="
echo ""

echo -n "REMnux (192.168.60.100): "
if ping -c 1 -W 2 192.168.60.100 > /dev/null 2>&1; then
    echo "UP"
else
    echo "DOWN"
fi

echo -n "Windows Victim (192.168.60.101): "
if ping -c 1 -W 2 192.168.60.101 > /dev/null 2>&1; then
    echo "UP"
else
    echo "DOWN"
fi

echo -n "pfSense SANDBOX (192.168.60.1): "
if ping -c 1 -W 2 192.168.60.1 > /dev/null 2>&1; then
    echo "UP"
else
    echo "DOWN"
fi

echo ""
echo "Done."
