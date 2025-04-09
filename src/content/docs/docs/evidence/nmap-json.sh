#!/usr/bin/env bash

# Install necessary tools
sudo apt-get update
sudo apt-get install -y nmap sqlite3

# Download and install nmap-formatter
VERSION=v2.1.0
curl -L "https://github.com/vdjagilev/nmap-formatter/releases/download/$VERSION/nmap-formatter-linux-amd64.tar.gz" -o nmap-formatter.tar.gz
tar -xzvf nmap-formatter.tar.gz
sudo mv nmap-formatter /usr/local/bin

# Create results directory
mkdir -p /home/nmap/result
cd /home/nmap



# Function to perform NMAP scan and save results to JSON
perform_nmap_scan() {
    local hostname=$1
    local ip=$2
    local provider=$3

    echo "Performing NMAP scan for $hostname ($ip) under $provider"
    local output_file="$hostname.xml"
    local json_output_file="/home/nmap/result/$hostname.json"

    # Run the Nmap scan
    nmap -p- -T4 --max-rtt-timeout 300ms "$ip" -oX "$output_file"
    echo "Converting NMAP results to JSON format"

    # Convert Nmap XML output to JSON
    nmap-formatter json "$output_file" > "$json_output_file"
    echo "JSON results saved to: $json_output_file"
}

# Read the ENDPOINTS environment variable, splitting on newlines
IFS=$'\n' read -rd '' -a ADDR <<< "$ENDPOINTS"
for entry in "${ADDR[@]}"; do
    # Split each line into parts based on the delimiter '|'
    IFS='|' read -ra PARTS <<< "$entry"
    if [ "${#PARTS[@]}" -eq 3 ]; then
        perform_nmap_scan "${PARTS[0]}" "${PARTS[1]}" "${PARTS[2]}"
    else
        echo "Skipping malformed entry: $entry"
    fi
done

echo "All NMAP scans completed. JSON results saved in /home/niba/nmap/json/test/"
echo "Running surveilr ingest files to generate the RSSD database..."
cd /home/nmap/result
surveilr ingest files

echo "RSSD database generated successfully!"