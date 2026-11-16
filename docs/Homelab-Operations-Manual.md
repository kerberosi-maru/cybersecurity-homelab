---
title: "Bennett's Homelab Operations Manual"
subtitle: "Cybersecurity lab: networks, hosts, workflows, and recovery"
---

**Revision:** 2.0, 16 November 2026 (supersedes v1.3 of July 25, 2026)  
**Owner:** Bennett Love ("Chief")  
**Repository:** github.com/kerberosi-maru/cybersecurity-homelab (public portfolio; this edition has not been pushed)  
**Prepared by:** Pip (XO), merging the manual versions of June 2026, June 28 and July 25, 2026, the repo docs (README and OpenVAS lab, Nov 2026), the May 2026 Sandbox Quick Reference, `homelab_current_status.md` (last updated Aug 20, file dated Sep 8), the Homelab Project Brief (Sep 16, 2026), and laptop checks done Nov 10 to 16, 2026.  
**Secrets:** none in this document. Credentials are "stored in password manager" (Bitwarden).  
**Companion document:** *Home Network Operations Manual* (2026-11-16). The house LAN (Zyxel gateway, Wi-Fi, 192.168.1.0/24, household devices), the WD My Cloud NAS, and the laptop backup jobs (Kopia, MyPassport mirror, Hasleo) are documented there and only summarized here.  

<!-- TOC -->
## Contents

- [1. Purpose and status](#1-purpose-and-status)
- [2. Architecture](#2-architecture)
  - [2.1 Networks](#21-networks)
  - [2.2 pfSense (VirtualBox VM on Chiefs_Laptop1)](#22-pfsense-virtualbox-vm-on-chiefs_laptop1)
  - [2.3 Host and device inventory](#23-host-and-device-inventory)
  - [2.4 Host networking details](#24-host-networking-details)
- [3. Access and aliases](#3-access-and-aliases)
- [4. Daily startup checklist](#4-daily-startup-checklist)
- [5. Malware analysis workflow](#5-malware-analysis-workflow)
  - [5.1 File transfer (host to Victim)](#51-file-transfer-host-to-victim)
  - [5.2 Victim VM configuration](#52-victim-vm-configuration)
  - [5.3 Static analysis (REMnux)](#53-static-analysis-remnux)
  - [5.4 Dynamic analysis](#54-dynamic-analysis)
- [6. Vulnerability scanning lab (OpenVAS and Metasploitable)](#6-vulnerability-scanning-lab-openvas-and-metasploitable)
- [7. Monitoring (SIEM / IDS)](#7-monitoring-siem-ids)
- [8. Backup and recovery (lab view)](#8-backup-and-recovery-lab-view)
- [9. Safety and reset rules](#9-safety-and-reset-rules)
- [10. Roadmap (from Sep 16 brief and status file)](#10-roadmap-from-sep-16-brief-and-status-file)
- [11. Needs verification](#11-needs-verification)
- [12. Version history](#12-version-history)
<!-- /TOC -->

# 1. Purpose and status

The lab is a personal, isolated environment for malware analysis and network defense practice, supporting certification study (SecurityX/CASP+, CBROPS, CCNA, CEH) and a SOC / network defense job search. As of the Sep 16, 2026 brief it is operational: networks are segmented, the host was fully recovered after the Aug 19 to 20 incident, and remaining work is capability expansion (self-cleaning sandbox, SIEM/IDS, automation).

# 2. Architecture

## 2.1 Networks

| Network | Subnet | Gateway | DHCP | Purpose |
|---|---|---|---|---|
| LANHOME | 192.168.10.0/24 | 192.168.10.1 (pfSense) | On (pfSense) | Lab management; Jumpbox and host management NIC |
| SANDBOX | 192.168.60.0/24 | 192.168.60.1 (pfSense) | Off (static IPs only) | Isolated analysis network; VirtualBox Internal Network named `sandbox` |
| pfSense WAN | Home LAN 192.168.1.0/24 (DHCP lease) | 192.168.1.1 (Zyxel) | From Zyxel | Lab uplink. See Home Network manual, section 9. |

Note: LANHOME is the lab management network, not the household LAN, despite the name. The household LAN is 192.168.1.0/24.

## 2.2 pfSense (VirtualBox VM on Chiefs_Laptop1)

| Interface | Attachment | Address |
|---|---|---|
| WAN | Bridged to the host's wireless adapter | DHCP from the home Zyxel (address not recorded) |
| LANHOME | Bridged to the Realtek PCIe GbE Family Controller (physical NIC) | 192.168.10.1/24 |
| SANDBOX | Internal Network `sandbox` | 192.168.60.1/24 |

Web UI: https://192.168.10.1 (from LANHOME). Admin credentials stored in password manager.

**SANDBOX firewall rules (locked Jul 13, 2026):**

1. Allow all intra-SANDBOX traffic.
2. Allow LANHOME to SANDBOX (management and Jumpbox access, scanner UI, SSH).
3. Allow SANDBOX to pfSense itself (routing and DNS).
4. Block SANDBOX to LANHOME.

Internet from SANDBOX is mostly blocked; controlled access is an open option, not a current feature.

## 2.3 Host and device inventory

| Host | IP | Network | Platform | Role / notes |
|---|---|---|---|---|
| pfSense | 192.168.10.1 / 192.168.60.1 | LANHOME / SANDBOX | VirtualBox VM | Lab firewall and router |
| Windows host (Chiefs_Laptop1) | 192.168.10.100 | LANHOME | Windows 11 Pro laptop (Lenovo G15 per Aug notes); 256 GB WD SN740 system disk | Static IP on Realtek NIC, **no default gateway** (avoids conflicts with Wi-Fi and ProtonVPN). Also 192.168.1.35 on the home Wi-Fi. Runs VirtualBox and WSL. |
| Jumpbox | 192.168.10.50 | LANHOME | Physical HP Pavilion dm4, Ubuntu 22.04.5 LTS, i5 M 430, about 8 GB RAM | Clean management node; mosh/SSH with key auth; user `chief` |
| REMnux | 192.168.60.100 | SANDBOX | Physical machine per Jun to Nov docs (see N3) | Static analysis toolkit; netplan `/etc/netplan/01-netcfg.yaml`, NetworkManager disabled; credentials stored in password manager |
| Windows Victim | 192.168.60.101 | SANDBOX | VirtualBox VM | Detonation target; static IP, gateway/DNS 192.168.60.1 |
| Metasploitable | 192.168.60.102 | SANDBOX | VirtualBox VM | Vulnerable target for scanning labs |
| Greenbone / OpenVAS | 192.168.60.104 | SANDBOX | Greenbone Enterprise (trial) VM | Vulnerability scanner. The home workbook also lists an OpenVAS VM at 192.168.1.17 (see N4). Off except during scans. |
| Kali Linux | Not recorded | Not recorded | VM | Only referenced as an earlier "Kali + gvm" OpenVAS attempt; current status unknown (N6) |

## 2.4 Host networking details

- **WSL:** mirrored networking mode. The script `/usr/local/bin/homelab-routes.sh` runs from `~/.bashrc` on every WSL start:

```bash
ip route add 192.168.10.0/24 dev eth1 2>/dev/null
ip route add 192.168.60.0/24 via 192.168.10.1 dev eth1 2>/dev/null
```

- **Windows (temporary, for scanner UI):** `route add 192.168.60.0 mask 255.255.255.0 192.168.10.1`; remove with `route delete 192.168.60.0`.
- **Network drives:** the My Cloud (192.168.1.36) and the iMac are mapped by IP for VPN stability. Details in the Home Network manual.

# 3. Access and aliases

| Where | Alias | Command / action |
|---|---|---|
| WSL on Windows host | `jump` | `mosh chief@192.168.10.50` |
| Jumpbox | `remnux` | `ssh remnux@192.168.60.100` (password stored in password manager) |
| Jumpbox | `fileserver` | `python3 -m http.server 8000` |
| Jumpbox | `sandbox-capture` | `sudo tcpdump -i any -w /tmp/sandbox_capture.pcap` |
| Jumpbox | `sandbox-status` | Ping check of REMnux and the Victim |

Aliases live in `~/cybersecurity-homelab/scripts/aliases.sh` (repo also has `scripts/sandbox-status.sh`). Load with `source ~/cybersecurity-homelab/scripts/aliases.sh`.

# 4. Daily startup checklist

1. Start the pfSense VM.
2. Power on the Jumpbox.
3. On the Windows host, open WSL and run `jump`.
4. Run `sandbox-status`.
5. Start the file server (`fileserver`) if transferring samples.
6. Start the Windows Victim VM and revert it to the clean baseline snapshot.
7. Optional pings: 192.168.60.100 (REMnux), 192.168.60.101 (Victim), and 192.168.10.50 (Jumpbox, from LANHOME).

Quick checks: from REMnux, `ping 192.168.60.1` and `ping 192.168.60.101`; from the pfSense shell, `ping 192.168.60.100` and `ping 192.168.60.101`. From the Victim, `ping 8.8.8.8` should fail.

# 5. Malware analysis workflow

## 5.1 File transfer (host to Victim)

1. Put the zipped sample in `C:\Users\benne\Documents\Sandbox\Samples\`.
2. Start the upload server (`fileserver`).
3. From the host browser, upload to `http://192.168.60.100:8000/upload.html`.
4. On the Victim, browse to `http://192.168.60.100:8000` and download the file.

Note: the alias runs a plain `http.server` on the Jumpbox, while the URL points at REMnux and an upload page. Confirm which machine serves port 8000 (N7).

## 5.2 Victim VM configuration

| Setting | Value |
|---|---|
| IP / gateway / DNS | 192.168.60.101 static / 192.168.60.1 / 192.168.60.1 |
| Adapter | Internal Network `sandbox` |
| Windows Firewall | Off during active testing (current practice since July) |
| Defender real-time protection | Off during analysis |
| Baseline snapshot | "Tools Installed - Baseline" (June 28); older docs use "Clean-Base-State" (N8) |
| Tools | ProcMon, System Informer (formerly Process Hacker) |

## 5.3 Static analysis (REMnux)

```bash
cd ~/samples
file *.exe; md5sum *.exe; sha256sum *.exe
strings *.exe > strings.txt; less strings.txt
strings *.exe | grep -E "http|https|powershell|cmd|run|regsvr32|dll|exe|inject" | head -100
pefile sample.exe
objdump -d sample.exe | head -30
```

## 5.4 Dynamic analysis

- **Prepare:** revert the Victim to baseline; start ProcMon (filter on the sample name) and System Informer; on the Jumpbox run `sandbox-capture`.
- **Execute:** run the sample for at most 30 to 60 seconds; stop the capture with Ctrl+C; revert the Victim immediately.
- **Review:** ProcMon for registry writes, file creation, and injection; packets with `tcpdump -r /tmp/sandbox_capture.pcap -nn -A | less`.
- Record date, sample hash, findings, and lessons learned for every session.

# 6. Vulnerability scanning lab (OpenVAS and Metasploitable)

1. Metasploitable on Internal Network `sandbox`, 192.168.60.102/24, gateway .60.1; snapshot before scanning.
2. Greenbone VM on `sandbox`, 192.168.60.104/24; verify with `ping -c 3 192.168.60.102`.
3. From the host (LANHOME route in place) open `https://192.168.60.104`.
4. Target `Metasploitable` (192.168.60.102); task with scanner "OpenVAS Default", config "Full and fast"; allow 30 to 90+ minutes.
5. Export the report (PDF/HTML/XML); review High and Medium findings.
6. Cleanup: revert Metasploitable, shut down the scanner, remove the temporary route.

Rules: scanner credentials stored in password manager. Never point "Full and fast" at household devices; household scanning rules are in the Home Network manual, section 8.

# 7. Monitoring (SIEM / IDS)

| Capability | Status |
|---|---|
| Suricata on the pfSense SANDBOX interface | Listed in the May 2026 quick reference only; not mentioned since. Treat as unverified (N9). |
| Security Onion | Not integrated; earlier multi-host attempts failed. Planned doc `security-onion-deployment.md` not written. |
| Wireshark on REMnux, tcpdump on Jumpbox | Available |

# 8. Backup and recovery (lab view)

Full details are in the Home Network manual, section 7. Summary:

| Layer | Tool | What it covers | Where |
|---|---|---|---|
| Files and VMs | Kopia 0.23.1 | Desktop, Documents, Pictures, Homelab VMs, School VMs; 6 AM and 6 PM CT | `F:\Backups\Homelab backups\Kopia Homelab Snapshots` on the My Cloud, mirrored to MyPassport `H:\Kopia Repo Mirror` |
| System image | Hasleo Backup Suite 6.0.2 (paid) | Disk 1 (system disk); daily 4 AM incremental plus weekly full | `\\192.168.1.36\chief\Backups\WindowsHost-Images\Chiefs_Laptop1_v2` |
| Jumpbox | None | Not backed up (open item) | n/a |
| REMnux / Victim | VirtualBox snapshots (Victim); none recorded for REMnux | Rebuild from baseline | n/a |

System Restore is disabled; File History and Offline Files (CSC) are disabled (Aug 20).

**Host recovery procedure (from the Aug 19 to 20 incident):**

1. Boot the rescue media: press F12 (or Fn+F12) at power-on on the laptop.
2. The rescue environment cannot reliably reach the NAS. Restore from a full image on local media (copy the latest full `.DBI` to the MyPassport first if needed).
3. After restore: confirm File History and Offline Files are off, run a full AV scan, then take a fresh Hasleo full.
4. Rebuild the emergency disk after Hasleo upgrades (the disk is on the thumbdrive labeled "WIN Rescue"; current build is from Jul 24).

# 9. Safety and reset rules

- Never execute malware on the Windows host.
- Revert the Victim VM to a clean snapshot after every run.
- Keep samples zipped until analysis.
- Run `sandbox-status` regularly to confirm connectivity and isolation.
- Keep SANDBOX on the Internal Network `sandbox`; never bridge it to a physical adapter.
- Keep the host LANHOME NIC without a default gateway.
- Take a new Hasleo full after any major host change.

# 10. Roadmap (from Sep 16 brief and status file)

1. Self-cleaning sandbox: automatic Victim revert on VM close.
2. Add the Jumpbox to backups.
3. Push current documentation to GitHub.
4. Pilot Vagrant/Ansible now that the `sandbox` name is stable.
5. Security Onion / SIEM integration.
6. Controlled internet for SANDBOX (optional).
7. Rebuild the WD Red NAS (old MyBook Pro RAID failed).
8. Parked: portable ESP32 Wi-Fi packet sniffer; AI alert triage.

# 11. Needs verification

| # | Item | Why | Who |
|---|---|---|---|
| N1 | Lab connectivity and SANDBOX isolation still work end to end | Last confirmed Jul 13 / Jul 25 | Chief (run startup checklist) |
| N2 | pfSense WAN address and whether lab traffic should move behind the planned home firewall | Not recorded; affects home hardening Q15 | Pip (VirtualBox on laptop) |
| N3 | Is REMnux physical or a VM? | Docs say physical, but a physical box cannot join a VirtualBox Internal Network | Chief |
| N4 | OpenVAS address: 192.168.60.104 (SANDBOX) vs 192.168.1.17 (home LAN) | Conflicting sources; a scanner with a home-LAN leg weakens isolation | Chief / Pip |
| N5 | Metasploitable and Greenbone VMs still present | Only in Nov repo docs | Pip (VBoxManage list vms) |
| N6 | Kali Linux VM: exists? IP and role | Requested in scope; not in any source | Chief / Pip |
| N7 | Which host serves the port 8000 upload page | Alias says Jumpbox, URL says REMnux | Chief |
| N8 | Current Victim baseline snapshot name | "Tools Installed - Baseline" vs "Clean-Base-State" | Pip (VBoxManage snapshot list) |
| N9 | Suricata on pfSense SANDBOX interface | Only in May 2026 guide | Chief (pfSense UI) |
| N10 | Laptop model (Lenovo G15) and boot key | From Aug notes only | Pip (system info) |
| N11 | WSL route script and mirrored mode still in place | Not checked since July | Pip |
| N12 | Change REMnux default password; confirm it is in the password manager | Closed Nov 16 (owner decision; REMnux stays on the isolated SANDBOX, see N1) | Chief |
| N13 | Rebuild the emergency boot disk ("WIN Rescue" thumbdrive) on Hasleo 6.0.2 | On the "WIN Rescue" thumbdrive; rebuild pending | Chief |
| N14 | Whether the public GitHub manual should be updated (and the password line removed) | Approved Nov 16: push the Nov 16 manual (no credentials) to replace the repo copy. Old line remains in git history unless rewritten | Chief |

# 12. Version history

| Date | Version | Notes |
|---|---|---|
| May 2026 | 1.0 | Original manual and Sandbox Quick Reference |
| June 2026 | 1.1 | Markdown conversion and formatting |
| June 28, 2026 | 1.2 | Bridged SANDBOX design, Victim configuration, firewall rules, snapshot strategy |
| July 25, 2026 | 1.3 | Post-reset restoration: Hasleo imaging, Kopia reconnect, WSL mirrored mode, LANHOME IPs, routes, mosh/SSH keys, aliases, drives by IP; SANDBOX moved to Internal Network |
| Nov 16, 2026 | 2.0 | Merged all versions and status sources; added OpenVAS/Metasploitable lab, monitoring status, recovery procedure, current backup facts; household network moved to the Home Network Operations Manual; credentials removed |
