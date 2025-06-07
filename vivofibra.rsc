#
# CONFIGURAÇÃO COMPLETA DO MIKROTIK COM PROVEDOR VIVO FIBRA.
# Testes foram realizados com sucesso e está funcionando dentro dos parâmetros normais de funcionamento
#
/interface bridge add admin-mac=87:13:1B:1D:D5:0D auto-mac=no comment=defconf name=bridgeLocal port-cost-mode=short
/interface ethernet set [ find default-name=ether1 ] comment=Internet
/interface ethernet set [ find default-name=ether2 ] comment=Switch1
/interface ethernet set [ find default-name=ether3 ] comment=Switch2
/interface ethernet set [ find default-name=ether4 ] comment=Sala
/interface ethernet set [ find default-name=ether5 ] comment="WiFi AP"
/interface pppoe-client add add-default-route=yes comment="VIVO Fibra PPPoE" disabled=no interface=ether1 name=pppoe-out1 password=cliente@cliente use-peer-dns=yes user=cliente
/interface list add name=WAN
/interface list add name=LAN
/interface lte apn set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/ip dhcp-server option add code=26 name=ip-dhcp-server-option-26 value="'1480'"
/ip pool add name=main ranges=192.168.88.2-192.168.88.254
/ip dhcp-server add address-pool=main interface=bridgeLocal lease-time=10m name=dhcp1
/ipv6 pool add name=pool-wg prefix=fd02:21::/64 prefix-length=64
/port set 0 name=serial0
/ip smb set domain=WORKGROUP enabled=yes interfaces=bridgeLocal
/interface bridge port add bridge=bridgeLocal comment=defconf disabled=yes ingress-filtering=no interface=ether1 internal-path-cost=10 path-cost=10
/interface bridge port add bridge=bridgeLocal comment=defconf hw=no ingress-filtering=no interface=ether2 internal-path-cost=10 path-cost=10
/interface bridge port add bridge=bridgeLocal comment=defconf hw=no ingress-filtering=no interface=ether3 internal-path-cost=10 path-cost=10
/interface bridge port add bridge=bridgeLocal comment=defconf hw=no ingress-filtering=no interface=ether4 internal-path-cost=10 path-cost=10
/interface bridge port add bridge=bridgeLocal comment=defconf hw=no ingress-filtering=no interface=ether5 internal-path-cost=10 path-cost=10
/ip firewall connection tracking set udp-timeout=10s
/ip neighbor discovery-settings set discover-interface-list=LAN
/ipv6 settings set max-neighbor-entries=8192
/interface detect-internet set detect-interface-list=WAN internet-interface-list=WAN lan-interface-list=LAN wan-interface-list=WAN
/interface list member add interface=pppoe-out1 list=WAN
/interface list member add interface=bridgeLocal list=LAN
/interface ovpn-server server add auth=sha1,md5 mac-address=FE:19:33:70:A7:22 name=ovpn-server1
/ip address add address=192.168.88.1/24 interface=bridgeLocal network=192.168.88.0
/ip cloud set ddns-enabled=yes
/ip dhcp-server network add address=192.168.88.0/24 comment="Standard IP Block" dhcp-option=ip-dhcp-server-option-26 dns-server=192.168.88.1 domain=myhome.local gateway=192.168.88.1 ntp-server=200.160.7.186,201.49.148.135
/ip dns set allow-remote-requests=yes servers=1.1.1.1,1.0.0.1,2606:4700:4700::1111,2606:4700:4700::1001
/ip firewall filter add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
/ip firewall filter add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
/ip firewall filter add action=accept chain=input comment="defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
/ip firewall filter add action=drop chain=input comment="defconf: drop all not coming from LAN" in-interface-list=!LAN
/ip firewall filter add action=accept chain=forward comment="defconf: accept in ipsec policy" ipsec-policy=in,ipsec
/ip firewall filter add action=accept chain=forward comment="defconf: accept out ipsec policy" ipsec-policy=out,ipsec
/ip firewall filter add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related hw-offload=yes
/ip firewall filter add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
/ip firewall filter add action=drop chain=forward comment="defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
/ip firewall nat add action=masquerade chain=srcnat out-interface=pppoe-out1 protocol=udp src-port=123 to-ports=49152-65535
/ip firewall nat add action=masquerade chain=srcnat out-interface=pppoe-out1 out-interface-list=WAN
/ip ipsec profile set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5
/ip smb shares set [ find default=yes ] directory=/flash/pub disabled=no
/ipv6 address add address=::ce2d:e0ff:fef1:96e0 eui-64=yes from-pool=vivo-ipv6 interface=bridgeLocal no-dad=yes
/ipv6 dhcp-client add add-default-route=yes interface=pppoe-out1 pool-name=vivo-ipv6 request=prefix
/ipv6 firewall address-list add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
/ipv6 firewall address-list add address=::1/128 comment="defconf: lo" list=bad_ipv6
/ipv6 firewall address-list add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
/ipv6 firewall address-list add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
/ipv6 firewall address-list add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
/ipv6 firewall address-list add address=100::/64 comment="defconf: discard only " list=bad_ipv6
/ipv6 firewall address-list add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
/ipv6 firewall address-list add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
/ipv6 firewall address-list add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6
/ipv6 firewall filter add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
/ipv6 firewall filter add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
/ipv6 firewall filter add action=accept chain=input comment="defconf: accept ICMPv6" protocol=icmpv6
/ipv6 firewall filter add action=accept chain=input comment="defconf: accept UDP traceroute" port=33434-33534 protocol=udp
/ipv6 firewall filter add action=accept chain=input comment="defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=udp src-address=fe80::/10
/ipv6 firewall filter add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 protocol=udp
/ipv6 firewall filter add action=accept chain=input comment="defconf: accept ipsec AH" protocol=ipsec-ah
/ipv6 firewall filter add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=ipsec-esp
/ipv6 firewall filter add action=accept chain=input comment="defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
/ipv6 firewall filter add action=drop chain=input comment="defconf: drop everything else not coming from LAN" in-interface-list=!LAN
/ipv6 firewall filter add action=accept chain=forward comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
/ipv6 firewall filter add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
/ipv6 firewall filter add action=drop chain=forward comment="defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
/ipv6 firewall filter add action=drop chain=forward comment="defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
/ipv6 firewall filter add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" hop-limit=equal:1 protocol=icmpv6
/ipv6 firewall filter add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=icmpv6
/ipv6 firewall filter add action=accept chain=forward comment="defconf: accept HIP" protocol=139
/ipv6 firewall filter add action=accept chain=forward comment="defconf: accept IKE" dst-port=500,4500 protocol=udp
/ipv6 firewall filter add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=ipsec-ah
/ipv6 firewall filter add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=ipsec-esp
/ipv6 firewall filter add action=accept chain=forward comment="defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
/ipv6 firewall filter add action=drop chain=forward comment="defconf: drop everything else not coming from LAN" in-interface-list=!LAN
/ipv6 firewall mangle add action=change-mss chain=forward in-interface=pppoe-out1 new-mss=1432 protocol=tcp tcp-flags=syn tcp-mss=1433-65535
/ipv6 firewall mangle add action=change-mss chain=postrouting new-mss=1432 out-interface=pppoe-out1 protocol=tcp tcp-flags=syn tcp-mss=1433-65535
/ipv6 firewall nat add action=src-nat chain=srcnat out-interface=pppoe-out1 protocol=udp src-port=123 to-ports=49152-65535
/ipv6 nd set [ find default=yes ] mtu=1492
/system clock set time-zone-name=America/Sao_Paulo
/system identity set name=Roteador1
/system resource irq rps set ether1 disabled=no
/system resource irq rps set ether2 disabled=no
/system resource irq rps set ether3 disabled=no
/system resource irq rps set ether4 disabled=no
/system resource irq rps set ether5 disabled=no
/system routerboard settings set auto-upgrade=yes
/tool mac-server set allowed-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN
