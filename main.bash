# Get the current IP to determine base IP automatically
# fix this for diff 
base_ip="10.39"

output_file="scan_results.txt"
> "$output_file"  # Clear file before starting

# Start the timer
start_time=$(date +%s)
echo "-------------------------------------------"

# Scan each IP in the subnet
for i in $(seq 0 127); do

    temp_end_time=$(date +%s)
    elapsed=$((temp_end_time - start_time))
    avg_time_per_ip=$((elapsed / (i + 1)))
    remaining_time=$((avg_time_per_ip * (127 - i)))

    percentage=$((i * 100 / 127))

    echo "Scan in progress for $elapsed seconds"
    echo "Estimated time remaining: $remaining_time seconds"
    echo "$percentage% IP addresses completed on this network"
    echo "-------------------------------------------"

    for j in $(seq 1 254); do
        ip="${base_ip}.${i}.${j}"
        
        # checking reachability
        if ping -c 1 -W 1 "$ip" &> /dev/null; then
            echo -e "\e[32m$ip is reachable\e[0m"
            echo -e "$ip is reachable" >> "$output_file"

            response=$(ping -c 1 -W 1 "$ip" | grep 'time=' | awk '{print $7}' | cut -d'=' -f2)
            echo "$ip is reachable with response time ${response} ms"

            # to be implemented - port scanning functionality
            
            #ip="192.168.1.10" 
            #for port in 22 80 443; do
            #    nc -zv -w 1 "$ip" $port &> /dev/null && echo -e "\e[32mPort $port is open on $ip\e[0m" || echo "Port $port is closed on $ip"
            #done

        else
            echo -e "$ip is not reachable" >> "$output_file"
        fi

        # Check for HTTP server response
        if curl -s --connect-timeout 1 "http://${ip}" &> /dev/null; then
            echo -e "\e[32m$ip has an HTTP server\e[0m"
            echo -e "$ip has an HTTP server" >> "$output_file"
        else
            echo "$ip does not respond to HTTP" >> "$output_file"
        fi
    done    

done


# End the timer and calculate elapsed time
end_time=$(date +%s)
elapsed=$((end_time - start_time))

echo "Results saved to $output_file"
echo "Scan completed in $elapsed seconds"