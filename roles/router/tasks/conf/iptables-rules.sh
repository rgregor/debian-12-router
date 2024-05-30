#!/usr/bin/env bash

################## Constants ##################

wan=WAN_PORT_TO_BE_FILLED
main_lan=LAN_PORT_TO_BE_FILLED
home_ipv4=192.168.0.0/24
home_ula=ULA_PREFIX_TO_BE_FILLED::/64


################## Default policies ##################

# forward DROP, input ACCEPT, output ACCEPT
# If set input to DROP, docker containers will stop working

iptables -P FORWARD DROP
ip6tables -P FORWARD DROP


################## Forward rules ##################

# NAT for outgoing v4 traffic
iptables -t nat -A POSTROUTING -o ${wan} -s ${home_ipv4} -j MASQUERADE

# Allow within main LAN
iptables -A FORWARD -i ${main_lan} -o ${main_lan} -j ACCEPT
ip6tables -A FORWARD -i ${main_lan} -o ${main_lan} -j ACCEPT

# Allow main LAN to WAN
iptables -A FORWARD -i ${main_lan} -o ${wan} -j ACCEPT
ip6tables -A FORWARD -i ${main_lan} -o ${wan} -j ACCEPT

# Only allow WAN to LAN established traffic
iptables -A FORWARD -i ${wan} -o ${main_lan} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -A FORWARD -i ${wan} -o ${main_lan} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT


################## Input rules ##################

# Allow DHCP & DHCPv6
iptables -A INPUT -i ${wan} -p udp --dport 68 --sport 67 -j ACCEPT
ip6tables -A INPUT -i ${wan} -p udp --dport 546 --sport 547 -j ACCEPT

# Allow ICMP Echo-Request (Ping)
iptables -A INPUT -p icmp --icmp-type echo-request -i ${wan} -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -i ${wan} -j ACCEPT
# Essential for proper path MTU discovery
iptables -A INPUT -p icmp --icmp-type fragmentation-needed -j ACCEPT
# Optionally, other types as needed:
iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT

# Allow ICMPv6 Echo Request and Echo Reply
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type echo-request -i ${wan} -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type echo-reply -i ${wan} -j ACCEPT
# Essential ICMPv6 messages for IPv6 operation
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type router-advertisement -i ${wan} -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type router-solicit -i ${wan} -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type neighbor-solicit -i ${wan} -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type neighbor-advertisement -i ${wan} -j ACCEPT
# Necessary for path MTU discovery
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type packet-too-big -j ACCEPT
# Handling multicast listener reports (important for multicast routing)
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 130 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 131 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 132 -j ACCEPT
# Other types of ICMPv6 packets
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type time-exceeded -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type destination-unreachable -j ACCEPT


# Only allow established connections from WAN
iptables -A INPUT -i ${wan} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i ${wan} -j DROP
ip6tables -A INPUT -i ${wan} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -i ${wan} -j DROP

# Accept all incoming traffic on main LAN interface (main LAN has full access)
iptables -A INPUT -i ${main_lan} -j ACCEPT
ip6tables -A INPUT -i ${main_lan} -j ACCEPT
