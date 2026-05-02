# Data Collection: SNS Experimental Trials

This directory serves as the primary repository for network and telemetry data collected during the evaluation of the **Secure Network System (SNS)**. The dataset characterizes the impact of various adversarial actions on a ROS 2-based TurtleBot3 platform.

> **Note on Data Access:** Due to the large size of the raw PCAP files (500MB+), full datasets including all PCAPs and CSV logs are hosted on Google Drive. Click the folder links in the sections below to access the raw data.

## 1. Experimental Overview
Each data collection trial represents a **10-minute scenario** conducted on a dedicated wireless network (SSID: `SNS`). 

* **Baseline Behavior:** During all trials, the controller executed the `babypark.py` script, commanding the robot to maintain a continuous elliptical movement pattern.
* **Nodes Involved:**
    * **Target Robot:** TurtleBot3 (logging battery and position).
    * **Controller:** Remote Ubuntu VM (sending ROS 2 commands).
    * **SOC:** Security Operations Center (ELK Stack monitoring + packet analysis).
    * **Offensive Pi:** Attacker node (executing `hping3` and `mdk4` payloads).

## 2. Scenario Matrix
| ID | Scenario | Attack Tool | Command / Intensity |
| :--- | :--- | :--- | :--- |
| **01** | **Baseline** | N/A | No Attack Traffic |
| **02** | **Deauth Flood** | `mdk4` | `sudo mdk4 wlan1 d -E [ssid]` |
| **03** | **ICMP Flood (Fast)**| `hping3` | `sudo hping3 -1 --flood [IP]` |
| **04** | **ICMP Flood (Slow)**| `hping3` | `sudo hping3 -1 --faster [IP]`|
| **05** | **MITM** | `iptables, scapy` | ARP Poisoning |
| **06** | **MITM + ICMP** | Mixed | Multi-vector Attack |
| **07** | **TCP SYN (Fast)** | `hping3` | `sudo hping3 -S -p 22 --flood [IP]`|
| **08** | **TCP SYN (Slow)** | `hping3` | `sudo hping3 -S -p 22 --faster [IP]`|
| **09** | **Watermarked 10ms** | N/A | Baseline + Security Overhead |
| **10** | **Watermarked 20ms** | N/A | Baseline + Security Overhead |

---

## 3. Detailed Scenario Data & Visualizations

### Scenario 01: Baseline
*Establishment of "Ground Truth" normal operations.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1Emb9Fh4wFoTK1m9q4UhB7hAO5EcBg1we?usp=sharing)**
* **Path Visual:**
![Path 01](./01_baseline/dashboard.png)

### Scenario 02: Deauth Flood
*Link-layer disruption targeting 802.11 management frames.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1P6GAt9j_r2C2sfsoB5Kgj9SEiOJFJAwO?usp=sharing)**
* **Path Visual:**
![Path 02](./02_deauth/dashboard.png)

### Scenario 03: ICMP Flood (Fast)
*High-intensity network saturation.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1CjnqMFcwN7X3a99coWRqVp6Uq_QsF8cT?usp=sharing)**
* **Path Visual:**
![Path 03](./03_icmp_fast/dashboard.png)

### Scenario 04: ICMP Flood (Slow)
*Stealthy congestion testing (10ms Watermark baseline).*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1l6y3R8FGFq58DN-JtWVGmtqNXZzl6ull?usp=sharing)**
* **Path Visual:**
![Path 04](./04_icmp_slow/dashboard.png)

### Scenario 05: MITM
*Man-in-the-Middle via ARP Poisoning.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1Qh7Q9BH3DmVNDE7er1gu4uG2q9fTH2C0?usp=sharing)**
* **Path Visual:**
![Path 05](./05_mitm/dashboard.png)

### Scenario 06: MITM + ICMP Flood
*Simultaneous multi-vector attack.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1H6oHqAzBxMCu_9sPfWDl_dSo5h5JMI6i?usp=sharing)**
* **Path Visual:**
![Path 06](./06_mitm_icmp/dashboard.png)

### Scenario 07: TCP SYN Flood (Fast)
*Exhaustion of TCP connection resources.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/17c8tX8jVLQTxvLKLxb6E9aLzIszZoyRX?usp=sharing)**
* **Path Visual:**
![Path 07](./07_tcp_fast/dashboard.png)

### Scenario 08: TCP SYN Flood (Slow)
*Stealthy connection exhaustion (10ms Watermark baseline).*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1ISpE9Ex7RgJmawfyHn_cgTTP5xQF686l?usp=sharing)**
* **Path Visual:**
![Path 08](./08_tcp_slow/dashboard.png)

### Scenario 09: Watermarked 10ms
*Baseline for system with 10ms security overhead.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1Z2ilmF6upx_B8f9LFApKIqesSr3Qcek9?usp=sharing)**
* **Path Visual:**
![Path 09](./09_wm_10ms/dashboard.png)

### Scenario 10: Watermarked 20ms
*Baseline for system with 20ms security overhead.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1A8HTThksIgNDcQN8EOQWpXheZRW-yclo?usp=sharing)**
* **Path Visual:**
![Path 10](./10_wm_20ms/dashboard.png)

---

## 4. Key Performance Observations
Initial analysis indicates a significant degradation of service during "Fast" (flood) scenarios:
* **Jitter:** Increased from a baseline of **0.5ms–0.6ms** to a range of **3ms–10ms** during active floods.
* **Packet Loss:** Increased from a baseline of **0.02%–0.08%** to **0.4%–1.6%** under adversarial pressure.
* **Navigation:** "Fast" flood attacks frequently resulted in telemetry lag, causing the robot to fail its elliptical pattern.

---
*Created for the SOC Data Collection Repository.*
