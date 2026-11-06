# OpenVAS Vulnerability Scan of Metasploitable

**Lab Exercise | College Class Experiment**  
**Date:** November 2026  
**Environment:** Bennett’s Cybersecurity Homelab – SANDBOX (192.168.60.0/24)

---

## Objective

Perform an authenticated vulnerability assessment of a deliberately vulnerable target (Metasploitable) using OpenVAS / Greenbone Vulnerability Management, while keeping the scan fully contained inside the isolated SANDBOX network.

## Lab Topology

| Host                    | IP Address       | Role                          | Network                  |
|-------------------------|------------------|-------------------------------|--------------------------|
| pfSense                 | 192.168.60.1     | Gateway / Firewall            | SANDBOX                  |
| Metasploitable          | 192.168.60.102   | Vulnerable target             | Internal Network `sandbox` |
| Greenbone Enterprise VM | 192.168.60.104   | Scanner (OpenVAS)             | Internal Network `sandbox` |
| Jumpbox / Windows Host  | 192.168.10.x     | Management / Report access    | LANHOME                  |

- SANDBOX is a VirtualBox Internal Network named `sandbox`.
- DHCP is disabled; all hosts use static addressing.
- Intra-SANDBOX traffic is allowed by pfSense.
- Management access from LANHOME → SANDBOX is permitted for UI and SSH.

## Tools

- Greenbone Enterprise (trial) / OpenVAS
- Metasploitable 2 (or 3)
- VirtualBox
- pfSense (existing lab firewall)

## Procedure

### 1. Prepare the Target
1. Import or create the Metasploitable VM.
2. Attach its network adapter to **Internal Network → `sandbox`**.
3. Assign a static IP (example: `192.168.60.102/24`, gateway `192.168.60.1`).
4. Take a clean snapshot before scanning.

### 2. Prepare the Scanner
1. Use an existing Greenbone Enterprise VM (or a working OpenVAS instance).
2. Attach its adapter to **Internal Network → `sandbox`**.
3. Assign a static IP (example: `192.168.60.104/24`, gateway `192.168.60.1`).
4. Verify reachability:
   ```bash
   ping -c 3 192.168.60.102
   ```

### 3. Access the Greenbone Web UI
From the Windows host (LANHOME), add a temporary route if needed:
```cmd
route add 192.168.60.0 mask 255.255.255.0 192.168.10.1
```
Then browse to:
```text
https://192.168.60.104
```

### 4. Configure and Run the Scan
1. **Configuration → Targets → New Target**
   - Name: `Metasploitable`
   - Hosts: `192.168.60.102`
2. **Scans → Tasks → New Task**
   - Name: `OpenVAS Metasploitable`
   - Scan Targets: Metasploitable
   - Scanner: OpenVAS Default
   - Scan Config: **Full and fast**
3. Start the task and allow it to complete (typically 30–90+ minutes).

### 5. Generate the Report
1. Go to **Scans → Tasks** and open the completed task.
2. Download the report in **PDF** (or HTML/XML) format.
3. Review High/Medium findings.

## Key Findings (Summary)

Metasploitable is intentionally vulnerable. A Full and fast scan normally returns a large number of findings, including:

- Outdated services (FTP, Telnet, SSH, HTTP, SMB, etc.)
- Default or weak credentials
- Known remote code execution vulnerabilities
- Information disclosure issues

*(Attach or link the actual PDF report in the repository if desired.)*

## Lessons Learned / Lab Notes

- Strong network isolation (Internal Network + pfSense rules) allowed safe scanning without risk to the home LAN.
- First-time OpenVAS/GVM feed synchronization and Scan Config loading can be time-consuming and memory-intensive.
- Using a pre-built Greenbone Enterprise appliance avoided many of the feed-rebuild issues encountered with a fresh Kali + `gvm` install.
- Management access via the existing LANHOME → SANDBOX path made the web UI reachable without placing a browser inside the sandbox.
- Always snapshot the target before scanning so the lab can be reset cleanly.

## Cleanup

1. Revert Metasploitable to the pre-scan snapshot.
2. Shut down the Greenbone scanner VM or return its adapter to its normal network if it is also used for other scans.
3. Remove the temporary Windows route if it is no longer needed:
   ```cmd
   route delete 192.168.60.0
   ```

---

**Related documentation:** [Homelab Operations Manual](Homelab-Operations-Manual.md)
