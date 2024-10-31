# Set base IP based on your current IP range
base_ip="10.39"

base_ip="192.168.1" # sub function
for i in $(seq 1 10); do
    ip="${base_ip}.${i}"
    response=$(ping -c 1 -W 1 "$ip" | grep 'time=' | awk -F'=' '{print $4}')
    if [ -n "$response" ]; then
        echo "$ip is reachable with response time $response ms"
    else
        echo "$ip is unreachable"
    fi
done


# Start scanning IPs from 10.39.0.1 to 10.39.127.254
for i in $(seq 0 127); do
    for j in $(seq 1 254); do

        ip="${base_ip}.${i}.${j}"
        
        # Ping each IP, suppress output
        ping -c 1 -W 1 "$ip" &> /dev/null
        
        # Check if ping was successful
        if [ $? -eq 0 ]; then
            echo "$ip is active"
        fi
    done
done

exit 1