IP Network Scanner

![Project Banner](example.png)

A simple IP network scanner built in C++ to identify active hosts within a specified range on a local network. It leverages socket programming and ICMP or TCP requests to detect active IP addresses.

Features

	•	Scans a range of IP addresses on a local network.
	•	Identifies active hosts by sending probe requests.
	•	Configurable scanning range and timeout settings.
 	•	Finds open ports and HTTP server responses.
	•	All the data is sent into a .txt file. 


Requirements

	•	C++11 or higher
	•	Networking libraries (e.g., sys/socket.h, arpa/inet.h for UNIX-based systems)
	•	Root/admin privileges for raw socket access (if using ICMP)
