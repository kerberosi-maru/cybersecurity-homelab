# 🛡️ Bennett's Cybersecurity Homelab

**Personal Portfolio Project | Malware Analysis • Network Defense • SOC Skills**

[![pfSense](https://img.shields.io/badge/pfSense-Firewall-blue?logo=pfsense)](https://www.pfsense.org/)
[![REMnux](https://img.shields.io/badge/REMnux-Malware%20Analysis-red)](https://remnux.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-Jumpbox-purple?logo=ubuntu)](https://ubuntu.com/)
[![Windows](https://img.shields.io/badge/Windows-Victim%20VM-blue?logo=windows)](https://www.microsoft.com/windows/)

**Version:** June 28, 2026  
**Status:** Active | Continuously Improved  
**Maintained by:** Bennett Love — U.S. Army Combat Veteran

---

## 🎯 Project Purpose

This repository documents my hands-on **cybersecurity homelab** built for practical skill development, certification preparation (SecurityX/CASP+, CBROPS, CCNA, CEH), and portfolio building as I transition into cybersecurity and IT roles.

**Current Focus Areas:**
- Segmented network design with pfSense
- Isolated malware analysis environment (hybrid virtual + physical)
- Static and dynamic malware analysis workflows
- Documentation and repeatable processes

The lab emphasizes **safety, repeatability, and clear documentation** — principles carried over from my military background in radar, electronic warfare, and targeting.

---

## 🏗️ Current Architecture (June 2026)

The lab currently uses a **hybrid virtual + physical** setup:

- **LANHOME** (192.168.10.0/24): Management network
- **SANDBOX** (192.168.60.0/24): Isolated analysis network (bridged to physical LAN adapter)
- **REMnux**: Now running as a physical machine connected via physical switch
- **Windows Victim VM**: Bridged to the same physical adapter as pfSense’s SANDBOX interface
- **pfSense**: Handles firewalling and routing between networks

This setup allows the Victim VM to communicate safely with both pfSense and the physical REMnux while remaining protected by firewall rules.

**Full detailed architecture, workflows, and configuration** are documented in the Operations Manual:

→ **[Homelab Operations Manual (v1.2)](docs/Homelab-Operations-Manual.md)**

---

## 📂 Repository Structure

```
cybersecurity-homelab/
├── README.md
├── docs/
│   └── Homelab-Operations-Manual.md     ← Main detailed manual (recommended starting point)
├── scripts/
│   ├── aliases.sh
│   └── sandbox-status.sh
├── images/          (screenshots & diagrams)
└── .gitignore
```

---

## 🚀 Getting Started

See the **[Operations Manual](docs/Homelab-Operations-Manual.md)** for:
- Current network architecture and diagrams
- Daily startup checklist
- File transfer workflow
- Static & dynamic analysis procedures
- Windows Victim VM configuration
- Safety rules

---

## 🔄 Recent Updates (June 28, 2026)

- Updated to hybrid virtual + physical architecture
- REMnux moved to physical machine
- Added detailed Windows Victim VM configuration section
- Updated baseline snapshot strategy
- Improved documentation formatting

---

## 📜 License

This project is licensed under the MIT License.

**Maintained by:** Bennett Love  
**GitHub:** https://github.com/kerberosi-maru/cybersecurity-homelab
