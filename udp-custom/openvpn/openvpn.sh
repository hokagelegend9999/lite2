#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Lite 2 v.30
# (C) Copyright 2023
# =========================================
# pewarna hidup
BGreen='\e[1;32m'
NC='\e[0m'
domain=$(cat /etc/xray/domain)
echo "$domain" > /root/domain
clear
MYIP=$(wget -qO- ifconfig.co);
MYIP2="s/xxxxxxxxx/$MYIP/g";
# // install squid for ubuntu 18/20
apt -y install squid3

# install squid for debian 11
sleep 1
echo "\e[1;32m Proses Download squid.. \e[0m"
apt -y install squid
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/hokagelegend2023/Lite2/main/udp-custom/openvpn/squid3.conf"
sed -i $MYIP2 /etc/squid/squid.conf

# // OpenVPN
sleep 1
echo "\e[1;32m Proses Download OpenVPN.. \e[0m"
wget https://raw.githubusercontent.com/hokagelegend2023/Lite2/main/udp-custom/openvpn/vpn.sh &&  chmod +x vpn.sh && ./vpn.sh

cd
chown -R www-data:www-data /home/vps/public_html
sleep 0.5
echo -e "$BGreen[SERVICE]$NC Restart All service SSH & OVPN"
/etc/init.d/nginx restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${BGreen}ok${NC} ] Restarting nginx"
/etc/init.d/openvpn restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${BGreen}ok${NC} ] Restarting cron "
/etc/init.d/ssh restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${BGreen}ok${NC} ] Restarting ssh "
/etc/init.d/dropbear restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${BGreen}ok${NC} ] Restarting dropbear "
/etc/init.d/fail2ban restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${BGreen}ok${NC} ] Restarting fail2ban "
/etc/init.d/stunnel4 restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${BGreen}ok${NC} ] Restarting stunnel4 "
/etc/init.d/vnstat restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${BGreen}ok${NC} ] Restarting vnstat "
/etc/init.d/squid restart >/dev/null 2>&1
clear
rm -rf openvpn.sh
sleep 5
cd
clear

