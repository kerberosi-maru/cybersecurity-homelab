# Bennett's Homelab Operations Manual

**Version:** July 25, 2026  
**Status:** Active & Fully Restored  
**Repository:** [github.com/kerberosi-maru/cybersecurity-homelab](https://github.com/kerberosi-maru/cybersecurity-homelab)

---

## 1. Network Architecture

| Component                  | IP Address       | Purpose                     | Notes                                              |
|----------------------------|------------------|-----------------------------|----------------------------------------------------|
| **LANHOME**                | 192.168.10.0/24  | Management network          | Primary management & Jumpbox network               |
| **Windows Host (LANHOME)** | 192.168.10.100   | Host management NIC         | Realtek PCIe GbE — static IP, **no default gateway** |
| **Jumpbox**                | 192.168.10.50    | Ubuntu control point        | Physical HP Pavilion dm4, Ubuntu 22.04.5 LTS       |
| **pfSense LANHOME**        | 192.168.10.1     | Gateway / Firewall          | Bridged to Realtek PCIe GbE                        |
| **SANDBOX**                | 192.168.60.0/24  | Malware analysis net        | Internal Network named `"sandbox"`                 |
| **pfSense SANDBOX**        | 192.168.60.1     | Sandbox gateway             | Internal Network adapter                           |
| **REMnux**                 | 192.168.60.100   | Analysis toolkit            | Physical machine, default user: `remnux` / `malware` |
| **Windows Victim VM**      | 192.168.60.101   | Detonation target           | Internal Network as configured                     |

### Key Design Notes (Updated July 25, 2026)

- **Windows host LANHOME interface:** Static 192.168.10.100 on Realtek PCIe GbE Family Controller. No default gateway (prevents routing conflicts with Wi-Fi / ProtonVPN).
- **WSL access:** Mirrored networking mode enabled. Routes for 192.168.10.0/24 and 192.168.60.0/24 added permanently via script.
- **Jumpbox access:** From WSL use the alias **`jump`** (`mosh chief@192.168.10.50`). SSH key authentication configured.
- **Network drives:** My Cloud (192.168.1.36) and Mac are mapped by IP address for VPN stability.
- **Isolation:** SANDBOX remains strongly isolated. Traffic from LANHOME → SANDBOX is allowed through pfSense for management. SANDBOX → LANHOME is blocked.

### pfSense SANDBOX Firewall Rules (Summary)

- Allow all intra-SANDBOX traffic (SANDBOX net ↔ SANDBOX net)
- Allow LANHOME → SANDBOX (management / Jumpbox access)
- Allow SANDBOX → pfSense self (routing + DNS)
- **Block** SANDBOX → LANHOME

**Windows Firewall on Victim VM:** Turned **off** during active testing/detonation for lab practicality.

---

## 2. Useful Aliases

### On WSL (Windows host)

| Command | Description                                      |
|---------|--------------------------------------------------|
| `jump`  | `mosh chief@192.168.10.50` → Connect to physical Jumpbox |

### On Jumpbox

| Command            | Description                                      |
|--------------------|--------------------------------------------------|
| `remnux`           | `ssh remnux@192.168.60.100` (password: malware)  |
| `fileserver`       | `python3 -m http.server 8000`                    |
| `sandbox-capture`  | `sudo tcpdump -i any -w /tmp/sandbox_capture.pcap` |
| `sandbox-status`   | Ping check for REMnux + Windows Victim           |

---

## 3. Backup Strategy (Updated July 25, 2026)

### System Image (Full Recovery)

- **Tool:** Hasleo Backup Suite Free v5.8.2.2
- **Type:** System Backup (OS + boot partitions)
- **Destination:** `\\192.168.1.36\chief\Backups\WindowsHost-Images`
- **Encryption:** AES-256
- **Schedule:** Full every Sunday + incrementals (retain ~4 fulls)
- **Rescue Media:** Bootable USB created + keep ISO copy on My Cloud
- **Note:** A new “golden” image should be taken after major configuration changes. Current baseline image (2026-07-24) is post-reset and incomplete pending full application reinstall.

### File & VM Backup

- **Tool:** Kopia (reconnected to existing repository)
- **Coverage:** VM folders + Documents + Desktop (and other configured policies)
- **Schedule:** Every 12 hours (as previously configured)
- **Destination:** WD My Cloud via SMB

### Other

- System Restore: Disabled (Hasleo provides stronger protection)
- File History: Can be disabled once Kopia is confirmed stable

---

## 4. Daily Startup Checklist

1. Start the **pfSense** VM
2. Power on the **Jumpbox** laptop
3. On Windows host, open WSL → type **`jump`**
4. Run connectivity check: **`sandbox-status`**
5. Start the file server: **`fileserver`**
6. Start the **Windows Victim VM** and **revert to clean snapshot**
7. (Optional) Verify full connectivity with pings to REMnux, Victim, and Jumpbox

---

## 5. WSL Homelab Routes (Permanent)

A script maintains the required routes after every WSL start:

**Path:** `/usr/local/bin/homelab-routes.sh`

```bash
ip route add 192.168.10.0/24 dev eth1 2>/dev/null
ip route add 192.168.60.0/24 via 192.168.10.1 dev eth1 2>/dev/null
```

Called automatically from `~/.bashrc`.

---

## 6. Safety & Reset Rules

- **Never** execute malware samples on the main Windows host
- **Always** revert the Victim VM to a clean snapshot after every run
- Keep samples zipped until ready for analysis
- Regularly run `sandbox-status` to verify connectivity and isolation
- After any major host change, take a new Hasleo system image

---

## 7. Version History

| Date         | Version | Notes |
|--------------|---------|-------|
| May 2026     | 1.0     | Original manual |
| June 2026    | 1.1     | Converted to Markdown + formatting improvements |
| June 28, 2026| 1.2     | Updated SANDBOX architecture (bridged), Victim VM config, firewall rules, snapshot strategy |
| July 25, 2026| 1.3     | Post-reset full restoration: Hasleo system imaging, Kopia reconnected, WSL mirrored mode, correct LANHOME IPs (host .100 / Jumpbox .50), permanent routes, mosh+SSH keys, aliases restored and corrected (remnux user), network drives mapped by IP. SANDBOX moved to true Internal Network isolation. |

---

**Maintained by:** Bennett Love  
**GitHub:** https://github.com/kerberosi-maru/cybersecurity-homelab
