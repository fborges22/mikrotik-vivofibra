#
# Este script corrige problemas que são observados com o uso do PPPoE na VIVO FIBRA
# Deverá ser utilizado para ajustar um roteador MIKROTIK já configurado previamente para corrigir problemas com a VIVO FIBRA
#

# Ajustar o TCP MSS em IPv6. Para MTU de 1492 bytes, alterar TCP MSS para 1432 bytes
/ipv6 firewall mangle add action=change-mss chain=forward in-interface=pppoe-out1 new-mss=1432 protocol=tcp tcp-flags=syn tcp-mss=1433-65535
/ipv6 firewall mangle add action=change-mss chain=postrouting new-mss=1432 out-interface=pppoe-out1 protocol=tcp tcp-flags=syn tcp-mss=1433-65535

# Contornar bloqueio/proteção da Vivo em UDP na porta 123 em IPv6. Isso vai evitar problemas em sincronizações NTP
/ipv6 firewall nat add action=src-nat chain=srcnat out-interface=pppoe-out1 protocol=udp src-port=123 to-ports=49152-65535

# Desabilitar EUI64 pois já está sendo especificado um endereço diferente
# Habilitar Duplicate Address Detection
/ipv6 address set [ find eui-64=yes from-pool=poolv6 interface=bridge no-dad=yes ] eui-64=no no-dad=no

# Anunciar o IP do roteador como DNS em IPv6. Hoje estão sendo anunciados os servidores da Vivo diretamente
# Anunciar para os clientes que usem MTU de 1492 bytes em IPv6
/ipv6 nd set [ find default=yes ] dns=fe80::4aa9:8aff:feba:5739 mtu=1492

# Contornar bloqueio/proteção da Vivo em UDP na porta 123 em IPv4. Isso vai evitar problemas em sincronizações NTP
/ip firewall nat add action=masquerade chain=srcnat out-interface=pppoe-out1 protocol=udp src-port=123 to-ports=49152-65535 place-before=0

# Recomendar para os clientes que usem MTU de 1492 bytes em IPv4. Nem todos seguem esta recomendação, mas ela é benéfica para aqueles que o fazem
/ip dhcp-server option add code=26 force=no name=ip-dhcp-server-option-26 value="'1480'"
/ip dhcp-server network set [ find gateway=192.168.77.1 ] dhcp-option=ip-dhcp-server-option-26