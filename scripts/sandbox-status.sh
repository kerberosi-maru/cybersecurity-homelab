#!/bin/bash
# sandbox-status.sh
# Quick connectivity and status check for Bennett's Homelab SANDBOX + LANHOME

echo "========================================"
echo "  Bennett's Cybersecurity Homelab"
echo "  SANDBOX + LANHOME Status Check"
echo "  $(date)"
echo "========================================"

echo ""
echo "🔹 LANHOME (192.168.10.0/24) - Jumpbox"
ping -c 2 -W 2 192.168.10.50 && echo "✅ Jumpbox reachable" || echo "❌ Jumpbox unreachable"

echo ""
echo "🔹 SANDBOX (192.168.60.0/24) - Isolated Analysis Network"
echo "Testing REMnux (192.168.60.100)..."
ping -c 2 -W 2 192.168.60.100 && echo "✅ REMnux reachable" || echo "❌ REMnux unreachable"

echo ""
echo "Testing Windows Victim VM (192.168.60.101)..."
ping -c 2 -W 2 192.168.60.101 && echo "✅ Windows Victim reachable" || echo "❌ Windows Victim unreachable"

echo ""
echo "🔹 pfSense Gateway Check (adjust IP if needed)"
# Example: ping pfSense LAN IP
ping -c 1 -W 1 192.168.10.1 && echo "✅ pfSense LAN gateway reachable" || echo "⚠️  pfSense check skipped or unreachable"

echo ""
echo "========================================"
echo "Status check complete. Review any failures above."
echo "========================================"
