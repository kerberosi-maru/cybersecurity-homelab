# 🛡️ Bennett's Cybersecurity Homelab

**Personal Portfolio Project | Malware Analysis • Network Defense • SOC Skills**

**Version:** November 2026  
**Status:** Active & Fully Restored  
**Maintained by:** Bennett Love — U.S. Army Combat Veteran

[![GitHub](https://img.shields.io/badge/GitHub-kerberosi--maru%2Fcybersecurity--homelab-blue?logo=github)](https://github.com/kerberosi-maru/cybersecurity-homelab)

---

## 🎯 Project Purpose

This repository documents my hands-on **cybersecurity homelab** built for practical skill development, certification preparation (SecurityX/CASP+, CBROPS, CCNA, CEH), and portfolio building as I transition into cybersecurity and IT roles.

**Current Focus Areas:**

- Strong network segmentation and isolation with pfSense
- Isolated malware analysis sandbox (Internal Network design)
- Static and dynamic malware analysis workflows (REMnux + Windows Victim)
- Vulnerability scanning with OpenVAS / Greenbone (Metasploitable lab)
- Reliable management via dedicated physical Jumpbox
- Robust backup and recovery strategy
- Clear, repeatable documentation and processes

The lab emphasizes **safety, isolation, repeatability, and clear documentation** — principles carried over from my military background in radar, electronic warfare, and targeting.

---

## 🏗️ Current Architecture (July 2026)

The lab uses a **hybrid virtual + physical** design with strong isolation:

| Network   | Subnet            | Purpose                          | Key Hosts / Notes                                      |
|-----------|-------------------|----------------------------------|--------------------------------------------------------|
| **LANHOME** | 192.168.10.0/24 | Management & Jumpbox network    | pfSense `.1`, Windows Host `.100`, Jumpbox `.50`      |
| **SANDBOX** | 192.168.60.0/24 | Isolated malware analysis       | Internal Network named `sandbox` (DHCP disabled)      |

**Core Components:**

- **pfSense** (VirtualBox VM)  
  - WAN: Bridged to host wireless  
  - LANHOME: Bridged to Realtek PCIe GbE  
  - SANDBOX: Internal Network `sandbox`

- **Jumpbox** — Physical HP Pavilion dm4 running Ubuntu 22.04.5 LTS  
  Primary clean management station (accessed via WSL + mosh)

- **REMnux** (192.168.60.100) — Physical analysis machine  
  Default user: `remnux`

- **Windows Victim VM** (192.168.60.101) — Detonation target  
  Reverted to clean snapshot after every run

- **Metasploitable** (192.168.60.102) — Vulnerable target for scanning labs  
- **Greenbone / OpenVAS** — Scanner used for vulnerability assessments inside the SANDBOX

**Firewall Policy Highlights (SANDBOX interface):**
- Allow all intra-SANDBOX traffic
- Allow LANHOME → SANDBOX (management only)
- Allow SANDBOX → pfSense self
- **Block** SANDBOX → LANHOME (strong isolation)

Full details, diagrams, daily checklists, aliases, and safety rules are in the Operations Manual.

→ **[Homelab Operations Manual (v1.3)](docs/Homelab-Operations-Manual.md)**

---

## 📂 Repository Structure

```
cybersecurity-homelab/
├── README.md
├── docs/
│   ├── Homelab-Operations-Manual.md          ← Primary documentation
│   └── OpenVAS-Metasploitable-Scan.md        ← Vulnerability scanning lab
├── scripts/
│   ├── aliases.sh
│   └── sandbox-status.sh
├── images/                            ← Architecture diagrams & screenshots
└── .gitignore
```

---

## 🚀 Getting Started / Daily Workflow

1. Start the **pfSense** VM
2. Power on the physical **Jumpbox**
3. From Windows host WSL → `jump` (mosh to Jumpbox)
4. Run `sandbox-status` to verify connectivity
5. Start file server (`fileserver`) if needed
6. Power on **Windows Victim VM** and **revert to clean snapshot**
7. Begin analysis (always keep samples zipped until ready)

See the Operations Manual for complete procedures, WSL route scripts, aliases, and safety rules.

---

## 🔄 Recent Updates (November 2026)

- Added **OpenVAS / Greenbone vulnerability scanning lab** against Metasploitable
- Documented safe scanning workflow inside the isolated SANDBOX
- Demonstrated management access to scanner UI from LANHOME without breaking isolation
- Lab write-up: [OpenVAS Metasploitable Scan](docs/OpenVAS-Metasploitable-Scan.md)

## 🔄 Previous Updates (July 25, 2026 — v1.3)

- **Post-Windows-reset full restoration** completed
- Network architecture locked to **Internal Network `"sandbox"`** for true isolation (major improvement over previous bridged design)
- WSL mirrored networking + permanent route script for reliable Jumpbox/REMnux/Victim access
- Jumpbox aliases restored and corrected (`remnux`, `sandbox-status`, `sandbox-capture`, `fileserver`)
- **Hasleo Backup Suite Free** system imaging + AES-256 encrypted baseline image + Rescue USB
- **Kopia** reconnected to existing repository; VM + Desktop snapshots running again
- Network drives remapped by IP for ProtonVPN stability
- Living status tracking + project continuity process established

**Previous major update (June 28, 2026 — v1.2):** Hybrid architecture, physical REMnux, improved Victim configuration and snapshot strategy.

---

## 🛡️ Safety First

- Never execute malware on the main Windows host
- Always revert the Victim VM to a clean snapshot after every detonation
- Keep samples compressed until analysis begins
- Regularly verify isolation with `sandbox-status`
- Take a new Hasleo system image after any major host change

---

## 📜 License

This project is licensed under the MIT License.

**Maintained by:** Bennett Love  
**GitHub:** https://github.com/kerberosi-maru/cybersecurity-homelab

---

*This lab is a living portfolio project. Documentation is updated as the environment evolves.*
