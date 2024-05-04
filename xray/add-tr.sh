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

tls="$(cat ~/log-install.txt | grep -w "Trojan WS TLS" | cut -d: -f2|sed 's/ //g')"
ntls="$(cat ~/log-install.txt | grep -w "Trojan WS none TLS" | cut -d: -f2|sed 's/ //g')"

# Function to count the number of IPs connected to the user
count_ips() {
    user_ips=$(netstat -tn | grep ESTABLISHED | grep trojan | grep ":$1" | awk '{print $5}' | cut -d: -f1 | sort | uniq)
    echo "$user_ips" | wc -l
}

while true; do
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m           TROJAN ACCOUNT          \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    read -rp "User: " -e user
    user_EXISTS=$(grep -w "$user" /etc/xray/config.json | wc -l)

    if [[ $user_EXISTS -eq '1' ]]; then
        clear
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\E[0;41;36m           TROJAN ACCOUNT          \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        echo "A client with the specified name was already created, please choose another name."
        echo ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        continue
    fi

    read -rp "Number of IPs (max 5): " -e num_ips
    if [[ $num_ips -lt 1 || $num_ips -gt 5 ]]; then
        echo "Number of IPs must be between 1 and 5."
        continue
    fi

    # Check if the number of IPs exceeds the limit
    if [[ $(count_ips $num_ips) -ge 5 ]]; then
        echo "Maximum number of IPs reached for this user."
        continue
    fi

    # Continue with the rest of the script
    read -rp "Expiration (days): " -e exp_days
    if [[ ! $exp_days =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a valid number."
        continue
    fi

    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp=$(date -d "+$exp_days days" +"%Y-%m-%d")
    sed -i '/#trojanws$/a\#! '"$user $exp"'\
    },{"password": "'"$uuid"'","email": "'"$user"'"' /etc/xray/config.json
    sed -i '/#trojangrpc$/a\#! '"$user $exp"'\
    },{"password": "'"$uuid"'","email": "'"$user"'"' /etc/xray/config.json

    trojanlink1="trojan://${uuid}@${domain}:${tls}?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=bug.com#${user}"
    trojanlink="trojan://${uuid}@${domain}:${tls}?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
    trojanlink2="trojan://${uuid}@${domain}:${ntls}?path=%2Ftrojan-ws&security=none&host=${domain}&type=ws#${user}"
    systemctl restart xray
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
    echo -e "\E[0;41;36m           TROJAN ACCOUNT           \E[0m" | tee -a /etc/log-create-trojan.log
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo -e "Remarks : ${user}" | tee -a /etc/log-create-trojan.log
echo -e "Host/IP : ${domain}" | tee -a /etc/log-create-trojan.log
echo -e "Wildcard : (bug.com).${domain}" | tee -a /etc/log-create-trojan.log
echo -e "Port TLS : ${tls}" | tee -a /etc/log-create-trojan.log
echo -e "Port none TLS : ${ntls}" | tee -a /etc/log-create-trojan.log
echo -e "Port gRPC : ${tls}" | tee -a /etc/log-create-trojan.log
echo -e "Key : ${uuid}" | tee -a /etc/log-create-trojan.log
echo -e "Path : /trojan-ws" | tee -a /etc/log-create-trojan.log
echo -e "ServiceName : trojan-grpc" | tee -a /etc/log-create-trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo -e "Link TLS : ${trojanlink}" | tee -a /etc/log-create-trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo -e "Link none TLS : ${trojanlink2}" | tee -a /etc/log-create-trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo -e "Link gRPC : ${trojanlink1}" | tee -a /etc/log-create-trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo -e "Expired On : $exp" | tee -a /etc/log-create-trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo "" | tee -a /etc/log-create-trojan.log
read -n 1 -s -r -p "Press any key to back on menu"
done
