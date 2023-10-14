####IMPORTANT NOTE####

If ip.txt is generated from a Linux machine, you'll need to edit the ropy6.sh to adjust the field used by awk. Specifically, change $3 to $5 in the following lines:

ips=$(cat "$1" | awk '{print $5}' | cut -d ":" -f1 | grep -E -v '^(0\.0|127|10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' | grep [0-9] | sort -u)
ports=$(cat "$1" | awk '{print $5}' | cut -d ":" -f2 | sort


netstat -ant > ip.txt
bash ropy6.sh ip.txt

To use in Windows
Pssst: Maybe it's time to switch to Linux ;)
