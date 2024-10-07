# Verifica se o arquivo "network-addiprange.sh" não existe
if ! [ -f "network-addiprange.sh" ]; then
  # Baixa o arquivo "network-addiprange.sh" a partir de um repositório GitHub
  curl -O https://raw.githubusercontent.com/extremeshok/xshok-proxmox/master/networking/network-addiprange.sh
  # Torna o arquivo executável
  chmod +x network-addiprange.sh
fi

# Verifica se o arquivo "network-addiprange.sh" contém a linha '#!/usr/bin/env bash'
# que indica que o script deve ser executado usando o interpretador bash
if ! grep -q '#!/usr/bin/env bash' "network-addiprange.sh"; then
  # Se a linha não estiver presente, imprime uma mensagem de erro
  echo "ERROR: network-addiprange.sh is invalid"
fi

# Verifica se o arquivo de configuração "/etc/sysctl.d/99-networking.conf" não existe
if ! [ -f "/etc/sysctl.d/99-networking.conf" ]; then
  # Se o arquivo não existir, cria um novo com as configurações de rede apropriadas
  echo "Creating /etc/sysctl.d/99-networking.conf"
  cat > /etc/sysctl.d/99-networking.conf <<EOF
net.ipv4.ip_forward=1                 # Habilita o encaminhamento de pacotes IPv4
net.ipv4.conf.eth0.send_redirects=0   # Desativa o envio de redirecionamentos ICMP para a interface eth0
net.ipv6.conf.all.forwarding=1        # Habilita o encaminhamento de pacotes IPv6
EOF
fi

# Obtém a interface de rede padrão usada pelo sistema
# Usando o comando `ip`, a rota é verificada e o nome da interface padrão é extraído
default_interface="$(ip -o route get 8/32 | grep -o 'dev [^ ]*' | xargs | cut -d' ' -f 2)"

# Cria ou sobrescreve o arquivo de configuração do isc-dhcp-server para definir
# quais interfaces o servidor DHCP vai usar (no caso, vmbr0 e vmbr1)
cat > /etc/default/isc-dhcp-server <<EOF
INTERFACESv4="vmbr0 vmbr1"
EOF

# Cria ou sobrescreve o arquivo de configuração DHCP com informações de sub-rede e intervalos de IP
# No caso, é uma sub-rede genérica que deve ser ajustada conforme sua rede
cat > /etc/dhcp/dhcpd.conf <<EOF
subnet 0.0.0.0 netmask 0.0.0.0 {
  range 10.10.10.100 10.10.10.200;   # Define o intervalo de endereços IP que o DHCP vai distribuir
  authoritative;                      # Define que o servidor DHCP é o autoritativo para essa sub-rede
  ...
}
EOF

# Habilita o serviço isc-dhcp-server para ser iniciado automaticamente no boot
systemctl enable isc-dhcp-server

# Exibe uma mensagem em amarelo, informando que o processo foi concluído e
# que o sistema precisa ser reiniciado
echo -e '\033[1;33m Finished....please restart the system \033[0m'
