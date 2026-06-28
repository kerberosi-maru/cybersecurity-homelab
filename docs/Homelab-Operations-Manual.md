# Bennett's Homelab Operations Manual

**Version:** June 28, 2026  
**Status:** Active & Improved  
**Repository:** https://github.com/kerberosi-maru/cybersecurity-homelab

---

## 1. Network Architecture

| Subnet / Component     | IP Address          | Purpose                              | Notes |
|------------------------|---------------------|--------------------------------------|-------|
| **LANHOME**            | 192.168.10.0/24    | Management & Jumpbox network        | Primary management network |
| Jumpbox                | 192.168.10.50      | Ubuntu laptop (main control point)  | Uses mosh + aliases |
| **SANDBOX** (Isolated) | 192.168.60.0/24    | Malware analysis network            | Currently bridged to physical LAN adapter on Windows host |
| REMnux                 | 192.168.60.100     | Malware analysis toolkit (physical) | Connected via physical switch |
| Windows Victim VM      | 192.168.60.101     | Safe execution environment          | Bridged to physical LAN adapter |
| pfSense                | —                  | Firewall + routing between networks | WAN + LAN + SANDBOX interfaces |

**Current Architecture Notes (June 2026):**
- The SANDBOX network uses a **bridged** connection to the physical LAN card on the Windows host. This was implemented because REMnux is now a physical machine connected through the physical switch.
- The Windows Victim VM is also bridged to the same physical adapter as pfSense’s SANDBOX interface.
- This hybrid setup (virtual + physical) allows the Victim to communicate with both pfSense and the physical REMnux while still being protected by pfSense firewall rules on the SANDBOX interface.

**Key Design Principles:**
- Strict network segmentation between management (LANHOME) and analysis (SANDBOX)
- Jumpbox is the only controlled entry point into the lab
- All analysis traffic is routed and inspected through pfSense

---

## 2. Useful Aliases (on Jumpbox)

| Command            | Description                                      |
|--------------------|--------------------------------------------------|
| `jump`             | Connect to Jumpbox via mosh                      |
| `remnux`           | SSH directly to REMnux                           |
| `fileserver`       | Start the Python upload web server               |
| `sandbox-capture`  | Start packet capture for sandbox traffic         |
| `sandbox-status`   | Quick connectivity & status check                |

**Tip:** Source the aliases file with:
```bash
source ~/cybersecurity-homelab/scripts/aliases.sh
```

---

## 3. Daily Startup Checklist

1. Start the **pfSense** VM
2. Power on the **Jumpbox** laptop
3. On your main Windows host, open WSL Ubuntu → type `jump`
4. Run connectivity check: `sandbox-status`
5. Start the file server: `fileserver`
6. Start the **Windows Victim VM**
   - Revert to **Tools Installed - Baseline** snapshot (or Clean-Base-State if doing a fresh run)
7. *(Optional)* Test full connectivity:
   - `ping 192.168.60.100` # REMnux
   - `ping 192.168.60.101` # Windows Victim
   - `ping 192.168.10.50`  # Jumpbox (from Victim)

---

## 4. File Transfer Workflow (Main Host → Victim VM)

**Recommended Method (Upload Server)**

1. Place the sample file (**keep it zipped**) in:  
   `C:\Users\benne\Documents\Sandbox\Samples\`

2. On the Jumpbox, run:
   ```bash
   fileserver
   ```

3. On your main Windows host browser, go to:  
   `http://192.168.60.100:8000/upload.html`

4. Upload the zipped sample

5. On the **Windows Victim VM**, open the browser and go to:  
   `http://192.168.60.100:8000` → download the file

---

## 5. Windows Victim VM Configuration (Current)

- **IP Address:** 192.168.60.101 (static)
- **Gateway / DNS:** 192.168.60.1 (pfSense)
- **Network Adapter:** Bridged to physical LAN card on Windows host (same as pfSense SANDBOX)
- **Windows Firewall:** Enabled with inbound rules from 192.168.10.0/24 (LANHOME)
  - ICMP (ping)
  - RDP (3389)
  - SMB (445) — optional
- **Windows Defender Real-time Protection:** Disabled during analysis
- **Current Baseline Snapshot:** Tools Installed - Baseline

> **Important:** Always revert to a clean snapshot after every malware execution.

---

## 6. Static Analysis Commands (on REMnux)

```bash
cd ~/samples

# Basic file identification
file *.exe
md5sum *.exe
sha256sum *.exe

# Extract strings for review
strings *.exe > strings.txt
less strings.txt                    # Use arrow keys, Page Up/Down, / to search, q to quit

# Focused interesting strings
strings *.exe | grep -E "http|https|powershell|cmd|run|regsvr32|dll|exe|360|paint|opencv|inject" | head -100
```

---

## 7. Dynamic Analysis Best Practices

### Preparation
- Revert Windows Victim VM to **Tools Installed - Baseline** snapshot
- Start **ProcMon** (with filter on sample filename)
- Start **System Informer** (formerly Process Hacker)
- On Jumpbox, run: `sandbox-capture`

### Execution
- Run the sample for **maximum 30–60 seconds**
- Stop capture with `Ctrl + C`
- **Immediately** revert the Victim VM to clean snapshot

### Review
- Open ProcMon log → look for registry writes, file creations, and process injections
- View the packet capture:
  ```bash
  tcpdump -r /tmp/sandbox_capture.pcap -nn -A | less
  ```

---

## 8. Safety & Reset Rules

- **Never** execute malware samples on your main Windows host
- **Always** revert the Victim VM to a clean snapshot after every run
- Keep samples zipped until ready for analysis
- Regularly run `sandbox-status` to verify connectivity and isolation
- Document every analysis session (date, sample hash, findings, lessons learned)

---

## Version History

| Date          | Version | Notes |
|---------------|---------|-------|
| May 2026      | 1.0     | Original manual |
| June 2026     | 1.1     | Converted to Markdown + formatting improvements |
| June 28, 2026 | 1.2     | Updated SANDBOX architecture (bridged to physical LAN), added Windows Victim VM configuration, Windows Firewall rules, and current snapshot strategy |

**Maintained by:** Bennett Love  
**GitHub:** https://github.com/kerberosi-maru/cybersecurity-homelab
