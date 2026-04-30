# 🛡️ Security Operations Center (SOC) Dashboard

A centralized monitoring and security analysis system for a robotic network, powered by the **ELK Stack** and **Kismet**.

---

## 📌 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Main Dashboard](#-main-dashboard)
- [Attack Detection](#-attack-detection)
- [Kismet Integration](#-kismet-integration)
- [Robot Dashboards](#-robot-dashboards)
- [MITM Detection](#-mitm-detection)
- [Kibana Tools](#-kibana-tools)
- [Usage](#-usage)

---

## 📡 Overview

The SOC uses the **ELK Stack**:

- **Elasticsearch** → Data storage  
- **Logstash** → Data processing pipeline  
- **Kibana** → Visualization dashboards  

Access Kibana:

```
http://192.168.0.76:5601
```

---

## 🧱 Architecture

![Network Diagram](https://github.com/user-attachments/assets/820ef3d8-37da-4194-b490-13e154734a95)

The network setup is centered around a router (192.168.0.1/24) that connects multiple devices on a local subnet (192.168.0.0/24). These include a controller laptop, several TurtleBot3 robots (Blinky, Inky, Pinky, and Clyde), an attack Raspberry Pi, and a Raspberry Pi 5 acting as a Security Operations Center. The SOC Pi is also connected via Ethernet to a separate subnet (10.0.0.0/24) with a monitoring Raspberry Pi. Dashed lines indicate Wi-Fi connections, while solid lines represent Ethernet connections.

---

## 📂 File Placement (Ubuntu)

### 🔧 Logstash Configuration Files
Place all Logstash config files in:

/etc/logstash/conf.d/

Files:
- 00-inputs.conf
- 09-metricbeat.conf
- 10-packetbeat.conf
- 11-heartbeat.conf
- 12-iperf.conf
- 20-ros.conf
- 21-suricata.conf
- 30-kismet.conf
- 32-arp.conf

Copy with:
sudo cp "Logstash Conf Files"/*.conf /etc/logstash/conf.d/

Restart Logstash after changes:
sudo systemctl restart logstash

---

### ⚙️ SOC YML Configuration Files
These are service configs for the ELK stack:

- kibana.yml → /etc/kibana/kibana.yml
- logstash.yml → /etc/logstash/logstash.yml
- elasticsearch.yml → /etc/elasticsearch/elasticsearch.yml

Example copy:
sudo cp "Soc YML Files"/kibana.yml.txt /etc/kibana/kibana.yml
sudo cp "Soc YML Files"/logstash.yml /etc/logstash/logstash.yml
sudo cp "Soc YML Files"/elasticsearch.yml.txt /etc/elasticsearch/elasticsearch.yml

---

### 🤖 Robot YMLs
Located in:
Robot YMLs/

These configs are meant to run on the robots themselves, not the SOC machine.  
They are included here as backup/reference copies only.

---

### 📊 Kibana Vega Diagrams
Located in:
Kibana Vega Diagrams/

These files are reference/backup Vega visualizations and:
- Do not need to be placed anywhere on the system
- Can be copied into Kibana manually when creating visualizations

---

### 🧰 Scripts

- scan_devices.sh  
  - Can be placed anywhere

Example:
chmod +x scan_devices.sh
./scan_devices.sh

---

## 📝 Notes
- .txt extensions on some YAML files are intentional (for storage/transfer). Remove .txt when placing them in system directories.
- Always restart services after updating configs:

sudo systemctl restart elasticsearch
sudo systemctl restart logstash
sudo systemctl restart kibana


---

## 📊 Main Dashboard

![Main Dashboard](https://github.com/user-attachments/assets/e7bbcfa0-ac3b-4914-a9e9-5e94a11f876a)

**Features:**
- Real-time robot fleet monitoring  
- Network traffic (KB/s)  
- Latency (ms)  
- Alert indicators  

### 🟢 Status Indicators

- ICMP Traffic  
- TCP Traffic  
- ARP Cache Integrity  

| Status | Meaning |
|--------|--------|
| 🟢 Green | Normal |
| 🔴 Red | Potential attack |

---

## 🚨 Attack Detection

### ICMP & TCP Flood

![Flood Attack](https://github.com/user-attachments/assets/4a990415-62c0-4332-9468-1f556ad7b9c9)

- High traffic triggers alerts  
- Severe cases may disconnect robots  

---

## 📶 Kismet Integration

### Network Security Panel

![Security Panel](https://github.com/user-attachments/assets/ecec9f80-5922-4aea-a041-7b324f30aac4)

- Detects **deauthentication attacks**
- Monitors last 5 minutes of activity  

### Status

- 🟢 No attack detected  
- 🔴 Deauth attack detected  

---

### 🔐 Access Kismet Dashboard

```
ssh -L 2501:10.0.0.2:2501 sns@192.168.0.76
```

Then open:

```
http://localhost:2501
```

**Login:**
- Username: sns  
- Password: sns  

---

### 📡 Dashboards under deauthentication attacks

![Main Deauth](https://github.com/user-attachments/assets/ae74571b-5853-4996-9137-535f61d36883)

![Deauth Attack](https://github.com/user-attachments/assets/b4a9b24e-ff46-4109-bbb5-e1b831ee2ec3)



---

## 🤖 Robot Dashboards

### Example: Inky

![Inky Dashboard](https://github.com/user-attachments/assets/61b06a46-1e17-4fae-a9d0-dd81078bc573)

**Includes:**
- Position tracking (odometry)
- Traffic metrics
- Latency & jitter

---

### 📈 Detailed Metrics

![Inky Metrics](https://github.com/user-attachments/assets/fa28fa99-cb5b-460e-9a0b-6bf8c6a2a870)

- UDP / TCP / ICMP breakdown  
- CPU, memory, disk usage  

---

### 🔐 ARP Cache Comparison

![ARP Comparison](https://github.com/user-attachments/assets/7cf8d6bf-eb66-4cf3-9f84-9e42ed0d3f76)

- Compares robot ARP vs network database  
- Highlights mismatches  

---

## 🕵️ MITM Detection

### Main Dashboard

![MITM Main](https://github.com/user-attachments/assets/521f99c1-9ace-4791-9315-139929b0f66c)

### Robot View

![MITM Robot](https://github.com/user-attachments/assets/78018413-99af-48ac-bdda-e64df2966b53)

**Indicators:**
- ARP mismatch  
- Incorrect MAC/IP mapping  

---

## 🔎 Kibana Tools

### Discover Panel

![Discover](https://github.com/user-attachments/assets/ae3d46d0-0063-4cf8-bc93-b6b4b1c83baf)

- View raw logs in real time  
- Debug data ingestion  

---

### 🗂️ Index Management

![Index](https://github.com/user-attachments/assets/5bd24359-8ca6-4145-b989-916293d2fa78)

- Manage Elasticsearch indices  
- Monitor storage & documents  

---

## 🛠️ Usage

### Update Network Device Database

Run on SOC Raspberry Pi:

```
./scan_devices.sh
```

---

## 🧠 Summary

This SOC system provides:

- 📡 Real-time monitoring  
- 🚨 Attack detection:
  - Traffic floods  
  - Deauthentication  
  - MITM / ARP spoofing  
- 🔍 Deep network visibility  

---

## ⚠️ Notes

- Ensure SSH tunnel is active for Kismet  
- Monitor ARP mismatches closely  
- Keep device database updated  
