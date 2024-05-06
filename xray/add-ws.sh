#!/bin/bash

MYIP=$(wget -qO- ipv4.icanhazip.com);
echo "Checking VPS"
clear
source /var/lib/ipvps.conf
if [[ "$IP" = "" ]]; then
    domain=$(cat /etc/xray/domain)
else
    domain=$IP
fi

# Function to count the number of IPs connected to the user
count_ips() {
    user_ips=$(netstat -tn | grep ESTABLISHED | grep xray | grep ":$1" | awk '{print $5}' | cut -d: -f1 | sort | uniq)
    echo "$user_ips" | wc -l
}

# Function to set the maximum number of IPs
set_max_ips() {
    clear
    echo "Choose IP Limit Option:"
    echo "1. Set IP Limit"
    echo "2. No IP Limit"
    read -p "Your choice [1-2]: " ip_choice
    case $ip_choice in
        1) read -rp "Enter maximum number of IPs (max 5): " -e max_ips ;;
        2) max_ips=0 ;;
        *) echo "Invalid choice. Defaulting to no IP limit." ; max_ips=0 ;;
    esac
}

while true; do
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;41;36m      Add Vmess Account      \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    read -rp "User: " -e user
    CLIENT_EXISTS=$(grep -w "$user" /etc/xray/config.json | wc -l)

    if [[ $CLIENT_EXISTS -eq '1' ]]; then
        clear
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\\E[0;41;36m      Add Vmess Account      \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        echo "A client with the specified name was already created, please choose another name."
        echo ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        continue
    fi

    set_max_ips  # Call the function to set maximum number of IPs

    # Check if the number of IPs connected to the user exceeds the limit
    if [[ $max_ips -gt 0 && $(count_ips "$user") -ge $max_ips ]]; then
        clear
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\\E[0;41;36m      Add Vmess Account      \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "The number of IPs connected to the user exceeds the limit of $max_ips."
echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to back on menu"
continue
fi
# Set the expiration date with month
read -rp "Expired (yyyy-mm-dd): " -e expire_date
expire_date_with_month=$(date -d "$expire_date" +"%Y-%m-%d")

# Add user to xray config
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "Adding User..."
sleep 2
echo -e "User: $user"
echo -e "Max IPs: $max_ips"
echo -e "Expired On: $expire_date_with_month"
echo -e "User successfully added to xray config!"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
# Add user to xray config here (replace with your logic)

read -n 1 -s -r -p "Press any key to back on menu"

