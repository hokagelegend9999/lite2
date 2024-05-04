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

while true; do
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;41;36m      Add Vless Account      \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    read -rp "User name: " -e user
    CLIENT_EXISTS=$(grep -w "$user" /etc/xray/config.json | wc -l)

    if [[ $CLIENT_EXISTS -eq '1' ]]; then
        clear
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\\E[0;41;36m      Add Vless Account      \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        echo "A client with the specified name already exists. Please choose another name."
        echo ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to go back to the menu"
        continue
    fi

    read -rp "Number of IPs (max 5): " -e num_ips
    if [[ $num_ips -lt 1 || $num_ips -gt 5 ]]; then
        echo "Number of IPs must be between 1 and 5."
        continue
    fi

    # Check if the user has exceeded the IP limit
    if [[ $(count_ips "$user") -ge $num_ips ]]; then
        echo "The user has reached the maximum number of allowed IPs."
        continue
    fi

    read -rp "Expiration months: " -e exp_months
    if [[ ! $exp_months =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a valid number."
        continue
    fi

    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp=$(date -d "+$exp_months months" +"%Y-%m-%d")
    sed -i '/#vless$/a\### '"$user $exp"'\
    },{"id": "'"$uuid"'","email": "'"$user"'"' /etc/xray/config.json

    systemctl restart xray > /dev/null 2>&1

    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vless.log
    echo -e "\\E[0;41;36m        Vless Account        \E[0m" | tee -a /etc/log-create-vless.log
    echo -e "\033[0;34m━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vless.log
    echo -e "Remarks        : ${user}" | tee -a /etc/log-create-vless.log
    echo -e "Domain         : ${domain}" | tee -a /etc/log-create-vless.log
    echo -e "Port           : 443" | tee -a /etc/log-create-vless.log
    echo -e "id             : ${uuid}" | tee -a /etc/log-create-vless.log
    echo -e "Security       : auto" | tee -a /etc/log-create-vless.log
    echo -e "Network        : tcp" | tee -a /etc/log-create-vless.log
    echo -e "Expired On     : $exp" | tee -a /etc/log-create-vless.log
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vless.log
    echo "" | tee -a /etc/log-create-vless.log
    read -n 1 -s -r -p "Press any key to go back to the menu"
    m-vless
    fi
