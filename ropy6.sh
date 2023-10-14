#!/bin/bash
##  The below APIs are my own, feel free to use in case you are lazy to create your own.
##  Create your own FREE APIs in https://www.abuseipdb.com/register , https://www.virustotal.com/gui/join-us

# Checking if the file is provided as an argument

malicious_count=0
abuseipdb_malicious_ips=()
vt_malicious_ips=()
shodan_open_ports=()

check_abuseipdb() {
    for ip in $ips; do
        echo "Checking $ip on AbuseIPDB..."
        response=$(curl -s -G https://api.abuseipdb.com/api/v2/check -d ipAddress="$ip" -H "Key: 896f5de33e4b761ba1bd5a7ede9323a5509ffde29c3694647547605f28b8e8d343c8f4c0c1ba2c55" -H "Accept: application/json")
        total_reports=$(echo "$response" | jq '.data.totalReports')

        if [[ $total_reports -gt 1 ]]; then
            malicious_count=$((malicious_count+1))
            abuseipdb_malicious_ips+=("$ip with $total_reports reports")
        fi
    done
}

check_virustotal() {
    for ip in $ips; do
        echo "Checking $ip on VirusTotal..."
        response=$(curl -s -G https://www.virustotal.com/api/v3/ip_addresses/$ip -H "x-apikey: e5f46a3cd28cdd765d16cba17e7cfad76c89e73af1c34b7e4fb822c3d28b17d0")
        malicious=$(echo "$response" | jq '.data.attributes.last_analysis_stats.malicious')
        suspicious=$(echo "$response" | jq '.data.attributes.last_analysis_stats.suspicious')

        if [[ $malicious -gt 1 ]] || [[ $suspicious -gt 1 ]]; then
            malicious_count=$((malicious_count+1))
            vt_malicious_ips+=("$ip with $malicious malicious and $suspicious suspicious reports")
        fi
    done
}

check_shodan() {
    for ip in $ips; do
        echo "Checking $ip on Shodan..."
        response=$(curl -s "https://api.shodan.io/shodan/host/$ip?key=yhNJYNgrjsoqeRRNcnLFmpYXkO3yNrGq")
        open_ports=$(echo "$response" | jq '.data[].port')
        if [[ ! -z "$open_ports" ]]; then
            shodan_open_ports+=("$ip with ports: $open_ports")
        fi
    done
}


if [ -z "$1" ] || ! cat "$1" > /dev/null 2>&1; then
    echo "Please save the output of netstat -ant in ip.txt and use it as an argument."; echo; echo "Example: bash ropy6.sh ip.txt"
	    exit 1

fi

# Interesting ports, add other ports which interest you in the below line.
interesting_ports=("3389" "5938" "5939" "6660-6670" "6697" "6901" "7070")

#Extract IPs and Ports ####IMPORTANT#### you need to EDIT the print $3 to print $5 if you used netstat -ant in linux, more info in README.md
#Edit the regex if you would like to include ipv6 etc..
ips=$(cat "$1" | awk '{print $3}' | cut -d ":" -f1 | grep -E -v '^(0\.0|127|10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' | grep [0-9] | sort -u)
ports=$(cat "$1" | awk '{print $3}' | cut -d ":" -f2 | sort -u)

while true; do

echo "1. Display all found public IPs"
echo "2. Display interesting ports"
echo "3. Check IP against AbuseIPDB"
echo "4. Check IP against VirusTotal"
echo "5. Check IP against Shodan"
echo "6. Aggressive mode (All Checks)"
echo "7. Summary"
echo "8. Exit"
echo -n "Choose an option: "
read option

case $option in
1)
    echo "Found public IPs are:"
    echo "$ips"
    ;;

2)
    echo "Found Interesting ports are:"
    for port in "${interesting_ports[@]}"; do
        if echo "$ports" | grep -q -E "$port"; then
            echo "$port"
        fi
    done
    ;;
3)
    check_abuseipdb
    ;;
4)
    check_virustotal
    ;;
5)
    check_shodan
    ;;
6)
    echo "Running in Aggressive Mode..."
    check_abuseipdb
    check_virustotal
    check_shodan
    ;;

7) # Summary Option
  echo "=== SUMMARY ==="
    echo "Total public IPs found: $(echo "$ips" | wc -l)"
    echo "Total malicious IPs detected: $malicious_count"
    echo "Malicious IPs flagged by AbuseIPDB:"
    for ip_report in "${abuseipdb_malicious_ips[@]}"; do
        echo " - $ip_report"
    done

    echo "Malicious IPs flagged by VirusTotal:"
    for ip in "${vt_malicious_ips[@]}"; do
        echo " - $ip"
    done

    echo "Open ports from Shodan:"
    for ip_ports in "${shodan_open_ports[@]}"; do
        echo " - $ip_ports"
    done
    ;;

8)
    echo "Hej då, Bye Bye, مع السلامة, Ciao"
    exit 0
    ;;

*)
    echo "Invalid option."
    ;;
esac

done