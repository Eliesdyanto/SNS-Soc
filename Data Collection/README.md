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

## 3. Data Glossary (File Definitions)
Each Google Drive folder contains 8 primary data artifacts. Below is the definition of each:

### Network Captures (PCAP)
* **`robot.pcap`**: Raw network traffic captured directly on the **TurtleBot3**. This is the "target's view" of the attack.
* **`soc.pcap`**: Traffic captured at the **ELK/SOC node**. This shows what data reached the monitoring system for analysis.
* **`controller.pcap`**: Traffic captured on the **Remote PC**. Used to verify if commands were successfully sent during network congestion.

### Telemetry & Logs (CSV)
* **`hb.csv` (Heartbeat)**: High-level availability logs; tracks if the communication link between the robot and SOC remained active.
* **`mb.csv` (Metricbeat)**: System resource logs; tracks CPU usage, RAM consumption, and system load (crucial for identifying resource exhaustion).
* **`pb.csv` (Packetbeat)**: Network flow metadata; summarizes protocol usage, source/destination IPs, and latency metrics.
* **`bat.csv` (Battery)**: Power telemetry from the TurtleBot3; used to measure the energy cost of processing attack traffic.
* **`pos.csv` (Position)**: Spatial odometry data (X, Y coordinates); used to track the robot's physical deviation from the intended path.

---

## 4. Detailed Scenario Data & Visualizations

### Scenario 01: Baseline
*Establishment of "Ground Truth" normal operations.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1FxCTRRNIy4ASC5SD-fq5Xkc4-XkhkMll?usp=sharing)**
* **Path Visual:**
![Path 01](./01_baseline/dashboard.png)

### Scenario 02: Deauth Flood
*Link-layer disruption targeting 802.11 management frames.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1W3IiokcF84-HL6FhYZg8-ewJY0UDb7Jl?usp=sharing)**
* **Path Visual:**
![Path 02](./02_deauth/dashboard.png)

### Scenario 03: ICMP Flood (Fast)
*High-intensity network saturation.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1hd-mCemsvpVBk7icGlg5mk3E5JMt7EFn?usp=sharing)**
* **Path Visual:**
![Path 03](./03_icmp_fast/dashboard.png)

### Scenario 04: ICMP Flood (Slow)
*Stealthy congestion testing (10ms Watermark baseline).*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1fBPkmXNwoo936hnV12K-TMsqY7ogzupm?usp=sharing)**
* **Path Visual:**
![Path 04](./04_icmp_slow/dashboard.png)

### Scenario 05: MITM
*Man-in-the-Middle via ARP Poisoning.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/10Qe6MAKcQqVOhgXXJfyKyaTMO76bM73b?usp=sharing)**
* **Path Visual:**
![Path 05](./05_mitm/dashboard.png)

### Scenario 06: MITM + ICMP Flood
*Simultaneous multi-vector attack.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1PHsesX-bfq3HM03c11sHGLpo-PG47VcL?usp=sharing)**
* **Path Visual:**
![Path 06](./06_mitm_icmp/dashboard.png)

### Scenario 07: TCP SYN Flood (Fast)
*Exhaustion of TCP connection resources.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1iuGEY4p72ekj45Q9H1uXaiyHucOSld5Y?usp=sharing)**
* **Path Visual:**
![Path 07](./07_tcp_fast/dashboard.png)

### Scenario 08: TCP SYN Flood (Slow)
*Stealthy connection exhaustion (10ms Watermark baseline).*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1iuGEY4p72ekj45Q9H1uXaiyHucOSld5Y?usp=sharing)**
* **Path Visual:**
![Path 08](./08_tcp_slow/dashboard.png)

### Scenario 09: Watermarked 10ms
*Baseline for system with 10ms security overhead.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1mv4nGHm3QsP-J1BR20kTy9odQKbRS4Ls?usp=sharing)**
* **Path Visual:**
![Path 09](./09_wm_10ms/dashboard.png)

### Scenario 10: Watermarked 20ms
*Baseline for system with 20ms security overhead.*
* 📂 **[Access Raw Data (Google Drive)](https://drive.google.com/drive/folders/1lqyNcjmtsPmfFBoaaG5UgmjfOoNmSMgb?usp=sharing)**
* **Path Visual:**
![Path 10](./10_wm_20ms/dashboard.png)

---

## 5. Key Performance Observations
Initial analysis indicates a significant degradation of service during "Fast" (flood) scenarios:
* **Jitter:** Increased from a baseline of **0.5ms–0.6ms** to a range of **3ms–10ms** during active floods.
* **Packet Loss:** Increased from a baseline of **0.02%–0.08%** to **0.4%–1.6%** under adversarial pressure.
* **Navigation:** "Fast" flood attacks frequently resulted in telemetry lag, causing the robot to fail its elliptical pattern.

---
*Created for the SOC Data Collection Repository.*
