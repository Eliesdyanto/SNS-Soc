This contains the documentation for the project
<img width="3244" height="1902" alt="SNS Diagram-Network Diagram drawio" src="https://github.com/user-attachments/assets/820ef3d8-37da-4194-b490-13e154734a95" />

Security Operations Center (SOC)
The Security Operations Center hosts the security information event manager software, elastic stack (ELK Stack). ELK stack consists of elasticsearch, logstash, and kibana. Elasticsearch is used as a database to store all of the information from the robots, logstash is the pipeline software used to turn all sources of data into a compatible format for elasticsearch, and kibana is the software used to draw all of the visuals and dashboards. To gain access to the ELK stack, type 192.168.0.76:5601 in the address bar of a browser. This will bring up the Kibana dashboard.


Figure 1: Main Dashboard

Figure X illustrates the main dashboard, which provides an overview of the robot fleet. It displays key metrics such as inbound and outbound network traffic (KB/s) and latency (ping in ms), along with the current alert status for each robot.

The dashboard includes several status indicators derived from Packetbeat data. These indicators monitor different types of network traffic, including ICMP and TCP. When traffic levels remain within expected thresholds, the indicators display a normal (green) status (e.g., “ICMP Count Normal”, “TCP Count Normal”). If Packetbeat detects unusually high levels of ICMP or TCP traffic, the corresponding indicator will turn red to signal a potential issue.

Additionally, the dashboard monitors ARP cache consistency. Each robot’s ARP cache is uploaded to the ELK stack and compared against a reference database generated from a full network ARP scan. If any discrepancies are detected between the robot’s ARP cache and the reference data, the ARP Cache indicator will turn red. Otherwise, it displays “No Mismatch in ARP Cache” when the data is consistent.

Figure 2: Main Dashboard under ICMP and TCP Flood attacks
	Figure X shows an example of a robot under an ICMP and TCP flood. Note that if the attack is particularly strong, the robot will instead lose connection and show the robot as offline.



Figure 3: Main Dashboard Continued

The large green panel displays the overall network security status. It indicates whether the network is currently experiencing a deauthentication attack. This is monitored using Kismet. If Kismet detects any deauthentication alerts within the last 5 minutes, the panel will turn red. If no alerts are detected, it remains green and displays “No Deauth Attack”.
This panel is also clickable. Clicking it will open the Kismet dashboard for more detailed information. Before accessing it, the user must create an SSH tunnel by running the following command in the terminal:
ssh -L 2501:10.0.0.2:2501 sns@192.168.0.76
Once this is done, open a web browser and go to:
http://localhost:2501
Login details:
 Username: sns
 Password: sns
The panel also contains a link to this local address (localhost:2501).
At the bottom of the dashboard is the network device database. This table shows devices currently detected on the network, including their MAC address and assigned IP address. It should represent all active devices on the network.
The database is updated by running the scan_devices.sh script on the SOC Raspberry Pi. This script performs a network scan and updates the database with any detected devices.


Figure 4: Kismet Dashboard
	The Kismet Dashboard is primarily used for detecting deauthentication attacks. Deauthentication attacks will appear in the dashboard in the “messages” section, as seen in the next figure.

Figure 5: Kismet Dashboard under deauthentication attack

Figure 6: Main Dashboard under a deauthentication attack
	Under a deauthentication attack, the entire panel will turn red. 


Figure :7 Inky Dashboard
From the main dashboard, a specific robot can be selected to view a more detailed dashboard. Figure 7 shows the dashboard for one of the robots, Inky.

This dashboard provides additional information about the robot’s activity. It includes an X vs Y positional graph based on the robot’s odometry (odom) data, allowing the user to track its movement. It also displays network statistics such as inbound and outbound traffic, as well as latency (ping) and jitter.



Figure 8: Inky Dashboard 2
Scrolling down provides additional details about the selected robot.
This section includes a breakdown of network traffic types, showing counts for UDP, TCP, and ICMP traffic. It also displays system metrics such as CPU usage, memory usage, and disk usage, giving an overview of the robot’s resource utilisation.
In addition, the robot’s ARP cache is shown here, listing the IP and MAC addresses of devices it can see on the network.


Figure 9: Inky Dashboard 3
Finally, the bottom section of the robot’s dashboard shows the robot’s ARP cache compared against the network ARP scan.
This panel displays the IP and MAC address mappings detected by the robot alongside the expected values from the database. Under normal conditions, these values should match. When they match, they are displayed in green. If there is a mismatch or a missing entry, it will be highlighted in red to indicate a potential issue.

Figure 10: Main Dashboard under man in the middle attack
Figure 10 shows an example of the main dashboard when a robot is under a man-in-the-middle (MITM) attack.
In this case, the ARP cache indicator panel turns red and displays “Alert: Mismatch Detected”. This indicates that the robot’s ARP cache does not match the expected values from the network database, suggesting a potential ARP spoofing or MITM attack.


Figure 11: Inky Dashboard under man in the middle attack.
Figure 11 shows the robot’s dashboard when it is under a man-in-the-middle (MITM) attack.
In this state, the ARP cache panel highlights issues in red. It displays the MAC addresses that each IP address is currently associated with, along with the intended MAC address that each IP should be assigned to.
If a mismatch is detected between the current and expected values, it is marked in red, indicating a potential ARP spoofing or MITM attack.





Figure 12: “Discover” panel in Kibana
Figure 12 shows the Discover panel.
This panel is used to view raw data within the ELK stack and is useful for verifying that data is being received correctly. It displays incoming logs and metrics in real time, allowing the user to inspect individual entries.
The Discover panel can be accessed by clicking the three-line menu icon in the top left of the interface.

Figure 13: Index Management
Figure 13 shows the Index Management page.
This page displays the indices stored in Elasticsearch, which contain the collected data. Each index represents a dataset, such as ARP cache data or network metrics, along with information like document count and storage size.
From this page, datasets (indices) can be managed or deleted if required.
