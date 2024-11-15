# Define base IP dynamically
base_ip="10.39"

# Output file
output_file="scan_results.txt"
> "$output_file"  # Clear file before starting

# JSON output file
json_output_file="scan_results.json"
echo "[]" > "$json_output_file"  # Initialize empty JSON

# Start timer
start_time=$(date +%s)
echo "-------------------------------------------"

# Function to calculate elapsed and estimated remaining time
time_tracking() {
    local index=$1
    temp_end_time=$(date +%s)
    elapsed=$((temp_end_time - start_time))
    avg_time_per_ip=$((elapsed / (index + 1)))
    remaining_time=$((avg_time_per_ip * (127 - index)))

    local percentage=$((index * 100 / 127))

    echo "Scan in progress for $elapsed seconds"
    echo "Estimated time remaining: $remaining_time seconds"
    echo "$percentage% IP addresses completed on this network"
    echo "-------------------------------------------"
}

# Function to ping an IP
ping_ip() {
    local ip=$1

    if ping -c 1 -W 1 "$ip" &> /dev/null; then
        echo -e "\e[32m$ip is reachable\e[0m"
        echo -e "$ip is reachable" >> "$output_file"

        response=$(ping -c 1 -W 1 "$ip" | awk -F'time=' '/time=/{print $2}' | awk '{print $1}')
        echo "$ip is reachable with response time ${response} ms"
        save_to_json "$ip" "reachable" "${response} ms"
    else
        echo -e "$ip is not reachable" >> "$output_file"
        save_to_json "$ip" "not reachable" "N/A"
    fi
}

# Function to check for HTTP server
check_http() {
    local ip=$1

    if curl -s --connect-timeout 1 "http://${ip}" &> /dev/null; then
        echo -e "\e[32m$ip has an HTTP server\e[0m"
        echo -e "$ip has an HTTP server" >> "$output_file"
        save_to_json "$ip" "HTTP server" "Yes"
    else
        echo "$ip does not respond to HTTP" >> "$output_file"
        save_to_json "$ip" "HTTP server" "No"
    fi
}

# Function to perform reverse DNS lookup
reverse_dns() {
    local ip=$1

    local hostname=$(nslookup "$ip" 2>/dev/null | awk -F 'name = ' '/name =/{print $2}' | tr -d '\n')
    if [ -n "$hostname" ]; then
        echo "$ip has hostname: $hostname" >> "$output_file"
        save_to_json "$ip" "reverse DNS" "$hostname"
    else
        echo "$ip has no reverse DNS entry" >> "$output_file"
        save_to_json "$ip" "reverse DNS" "None"
    fi
}

# Function to perform traceroute
run_traceroute() {
    local ip=$1

    echo "Traceroute for $ip:" >> "$output_file"
    traceroute_output=$(traceroute -m 5 "$ip" 2>/dev/null)
    echo "$traceroute_output" >> "$output_file"
    save_to_json "$ip" "traceroute" "$traceroute_output"
}

# Function to save results to JSON
save_to_json() {
    local ip=$1
    local key=$2
    local value=$3

    tmp=$(mktemp)
    jq ". += [{\"ip\": \"$ip\", \"$key\": \"$value\"}]" "$json_output_file" > "$tmp" && mv "$tmp" "$json_output_file"
}

# Function to generate a summary report
generate_summary() {
    total_reachable=$(grep -c "is reachable" "$output_file")
    total_http=$(grep -c "has an HTTP server" "$output_file")

    echo "Scan Summary:" >> "$output_file"
    echo "Total IPs scanned: $((128 * 254))" >> "$output_file"
    echo "Total reachable IPs: $total_reachable" >> "$output_file"
    echo "Total IPs with HTTP servers: $total_http" >> "$output_file"
}

# Main loop to scan IPs
for i in $(seq 0 127); do
    time_tracking $i

    for j in $(seq 1 254); do
        ip="${base_ip}.${i}.${j}"

        ping_ip "$ip"
        check_http "$ip"
        reverse_dns "$ip"
        run_traceroute "$ip"
    done
done

# End timer
end_time=$(date +%s)
elapsed=$((end_time - start_time))

echo "Results saved to $output_file"
echo "Scan completed in $elapsed seconds"
generate_summary