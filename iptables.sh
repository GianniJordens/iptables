#!/bin/sh

SIP="sudo iptables"

#flush iptables
$SIP -P INPUT ACCEPT
$SIP -P FORWARD ACCEPT
$SIP -P OUTPUT ACCEPT
$SIP -t nat -F
$SIP -t mangle -F
$SIP -F
$SIP -X

#loopback connectie
$SIP -A INPUT -i lo -s 127.0.0.1 -j ACCEPT
$SIP -A OUTPUT -o lo -s 127.0.0.1 -j ACCEPT

#allow security patch
$SIP -A OUTPUT -d security.debian.org -p tcp --dport 80 -j ACCEPT
$SIP -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#prevent ping flood
$SIP -t filter -A INPUT -p icmp --icmp-type echo-request -m limit --limit 5/minute -j ACCEPT
$SIP -t filter -A INPUT -p icmp -j DROP
$SIP -t filter -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

#Apache(http+https)
$SIP -A INPUT -p tcp -m multiport --dport 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
$SIP -A OUTPUT -p tcp -m multiport --dport 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#Proftpd
$SIP -A INPUT -p tcp -m multiport --dport 20,21 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
$SIP -A OUTPUT -p tcp -m multiport --dport 20,21 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#bind9
$SIP -A INPUT -p udp --dport 53 -j DROP
$SIP -A OUTPUT -p udp --dport 53 -j DROP

$SIP -P INPUT DROP
$SIP -P FORWARD DROP
$SIP -P OUTPUT DROP
