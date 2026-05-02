# Data Collection: SNS Experimental Trials

This directory serves as the primary repository for network and telemetry data collected during the evaluation of the **Secure Network System (SNS)**. The dataset characterizes the impact of various adversarial actions on a ROS 2-based TurtleBot3 platform.

## 1. Experimental Overview
Each data collection trial represents a **10-minute scenario** conducted on a dedicated wireless network (SSID: `SNS`). 

* **Baseline Behavior:** During all trials, the controller executed the `babypark.py` script, commanding the robot to maintain a continuous elliptical movement pattern.
* **Nodes Involved:**
    * **Target Robot:** TurtleBot3 (logging battery and position).
    * **Controller:** Remote Ubuntu VM (sending ROS 2 commands).
    * **SOC:** Security Operations Center (ELK Stack monitoring + packet analysis).
    * **Offensive Pi:** Attacker node (executing `hping3` and `mdk4` payloads).

## 2. Scenario Matrix
The following table outlines the 10 scenarios tested. 

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

## 3. Data Collection Methodology
We employed a multi-layered logging strategy to capture the "ground truth" of the network state.

### Network Captures (.pcap)
To ensure no data was missed due to local processing limits, captures were run simultaneously on three nodes:
1. **Robot:** Captured via `sudo timeout 600s tcpdump -i any -s 0 -w [scenario]_robot.pcap`.
2. **Controller:** Captured via `sudo tshark -i any -a duration:600 -w [scenario]_controller.pcap`.
3. **SOC:** Captured via `sudo tshark -i any -a duration:600 -w [scenario]_soc.pcap`.

### System & Security Logs (.csv)
The following CSV files were collected for each scenario:
* **Heartbeat:** Monitor node availability and uptime.
* **Metricbeat:** Resource utilization (CPU/RAM) across all SNS nodes.
* **Packetbeat:** Real-time network flow and protocol metadata.
* **Robot Battery:** Power consumption logs to detect "Energy Depletion" attacks.
* **Robot Position:** X/Y coordinate logs to visualize path deviation caused by network latency.

### Path Visualization
A `.png` screenshot is included for each scenario, visualizing the robot's actual path (captured via position logs) compared to the intended elliptical trajectory.

## 4. Key Performance Observations
Initial analysis indicates a significant degradation of service during "Fast" (flood) scenarios:
* **Jitter:** Increased from a baseline of **0.5ms–0.6ms** to a range of **3ms–10ms** during active floods.
* **Packet Loss:** Increased from a baseline of **0.02%–0.08%** to **0.4%–1.6%** under adversarial pressure.
* **Navigation:** "Fast" flood attacks frequently resulted in telemetry lag, causing the robot to fail its elliptical pattern.

---
*Created for the SOC Data Collection Repository.*
