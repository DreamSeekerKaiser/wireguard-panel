#!/bin/bash

#生成用户key
cd /etc/wireguard/userkey
wg genkey | tee $1privatekey | wg pubkey > $1publickey

#获取参数
c1 = $(cat $1privatekey)
c2 = $(cat $1publickey)
s2 = $(cat /etc/wireguard/spublickey)
userip = $(awk -F ',' '{print $3;}' /etc/wireguard/global)
serverip = $(awk -F ',' '{print $1;}' /etc/wireguard/global) 
prot = $(awk -F ',' '{print $2;}' /etc/wireguard/global)

#生成客户端配置文件
cat > /etc/wireguard/user/$1.conf <<-EOF
[Interface]
PrivateKey = $c1
Address = 10.0.0.$userip/24 
DNS = 8.8.8.8
MTU = 1420

[Peer]
PublicKey = $s2
Endpoint = $serverip:$port
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

#使用命令动态加载peer
wg set wg0 peer $c2 allowed-ips 10.0.0.$userip/32

#静态化写入配置文件
cat >> /etc/wireguard/wg0.conf <<-EOF
[peer]
PublicKey = $c2
AllowedIPs = 10.0.0.$userip/32
EOF




