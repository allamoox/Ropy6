#!/bin/bash
##  The below APIs are my own, feel free to use in case you are lazy to create your own.
##  Create your own FREE APIs in https://www.abuseipdb.com/register , https://www.virustotal.com/gui/join-us

# Checking if the file is provided as an argument
if [ -z "$1" ] || ! cat "$1" > /dev/null 2>&1; then
    echo "Please save the output of netstat -ant in ip.txt and use it as an argument."; echo; echo "Example: bash ropy6.sh ip.txt"
	    exit 1

fi

# Interesting ports
interesting_ports=("3389" "5938" "5939" "6660-6670" "6697" "6901" "7070")

# Extract IPs and Ports
ips=$(cat "$1" | awk '{print $3}' | cut -d ":" -f1 | grep -E -v '^(0\.0|127|10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' | grep [0-9] | sort -u)
ports=$(cat "$1" | awk '{print $3}' | cut -d ":" -f2 | sort -u)

while true; do

echo "1. Display all found public IPs"
echo "2. Display interesting ports"
echo "3. Check IP against AbuseIPDB"
echo "4. Check IP against VirusTotal"
echo "5. Aggressive mode (All Checks)"
echo "6. Exit"
echo -n "Choose an option: "
read option

case $option in
1)
    echo "Found public IPs:"
    echo "$ips"
    ;;

2)
    echo "Interesting ports:"
    for port in "${interesting_ports[@]}"; do
        if echo "$ports" | grep -q -E "$port"; then
            echo "$port"
        fi
    done
    ;;

3)
    for ip in $ips; do
        echo "Checking $ip on AbuseIPDB..."
        curl -s -G https://api.abuseipdb.com/api/v2/check -d ipAddress="$ip" -H "Key: 896f5de33e4b761ba1bd5a7ede9323a5509ffde29c3694647547605f28b8e8d343c8f4c0c1ba2c55	" -H "Accept: application/json" | jq
    done
    ;;

4)
    for ip in $ips; do
        echo "Checking $ip on VirusTotal..."
        curl -s -G https://www.virustotal.com/api/v3/ip_addresses/$ip -H "x-apikey: e5f46a3cd28cdd765d16cba17e7cfad76c89e73af1c34b7e4fb822c3d28b17d0" | jq
    done
    ;;

5)
    echo "Running in Aggressive Mode..."
    for ip in $ips; do
        echo "Checking $ip on AbuseIPDB..."
        curl -s -G https://api.abuseipdb.com/api/v2/check -d ipAddress="$ip" -H "Key: 896f5de33e4b761ba1bd5a7ede9323a5509ffde29c3694647547605f28b8e8d343c8f4c0c1ba2c55" -H "Accept: application/json" | jq
        
        echo "Checking $ip on VirusTotal..."
        curl -s -G https://www.virustotal.com/api/v3/ip_addresses/$ip -H "x-apikey: e5f46a3cd28cdd765d16cba17e7cfad76c89e73af1c34b7e4fb822c3d28b17d0" | jq
    done
    ;;

6)
    echo "Exiting..."
    exit 0
    ;;

*)
    echo "Invalid option."
    ;;
esac

# Wait for the user to press a key before exiting
##read -p "If nothing else, I can do for you...press 6 to exit"
done
