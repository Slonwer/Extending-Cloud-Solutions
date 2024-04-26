# Configuração do Token da API
pveum user add {{USERNAME}}@pve                   # Adiciona um usuário para autenticação
pveum group add admin -comment "Admin"            # Adiciona um grupo de administradores
pveum acl modify / -group admin -role Administrator  # Define as permissões de administrador para o grupo
pveum user modify {{USERNAME}}@pve -group admin   # Adiciona o usuário ao grupo de administradores
TOKEN=$(pveum user token add {{USERNAME}}@pve {{USERNAME}} --privsep=0 | sed -n '/│ value/s/.*│ value[[:space:]]*│[[:space:]]*\(.*\)│/\1/p')  # Gera o token de API
echo "export PM_API_TOKEN_SECRET=\"${TOKEN}\"" >> ~/.bashrc   # Adiciona o token de API ao arquivo de inicialização do bash
echo 'export PM_API_TOKEN_ID={{USERNAME}}@pve!{{USERNAME}}' >> ~/.bashrc  # Adiciona o ID do token de API ao arquivo de inicialização do bash

# Configuração da Rede NAT
cat <<EOF | sudo tee -a /etc/network/interfaces  # Adiciona configurações de rede ao arquivo /etc/network/interfaces
auto vmbr1                          # Configura a interface vmbr1 para iniciar automaticamente
iface vmbr1 inet static             # Define o endereço IP estático para a interface vmbr1
        address 192.168.1.1/24      # Endereço IP e máscara de sub-rede
        bridge-ports none           # Nenhum porta associada à bridge
        bridge-stp off              # Desativa o Spanning Tree Protocol
        bridge-fd 0                 # Define o tempo de forward delay como 0 (desativado)

        post-up echo 1 > /proc/sys/net/ipv4/ip_forward  # Habilita o IP forwarding
        post-up iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o vmbr0 -j MASQUERADE  # Configura NAT para a rede vmbr1
        post-down iptables -t nat -D POSTROUTING -s 192.168.1.0/24 -o vmbr0 -j MASQUERADE  # Remove a regra de NAT
EOF
ifup vmbr1   # Inicia a interface vmbr1

# Instalação e Configuração do Servidor DHCP
apt install isc-dhcp-server -y   # Instala o servidor DHCP
sed -i '17s/.*/INTERFACESv4="vmbr1"/' /etc/default/isc-dhcp-server  # Configura a interface de rede para o servidor DHCP
cat <<EOL > "/etc/dhcp/dhcpd.conf"   # Configura o arquivo de configuração do DHCP
option domain-name "example.org";   # Define o nome de domínio padrão
option domain-name-servers ns1.example.org, ns2.example.org;   # Define servidores DNS padrão

default-lease-time 600;   # Tempo padrão de concessão de IP
max-lease-time 7200;      # Tempo máximo de concessão de IP

subnet 192.168.1.0 netmask 255.255.255.0 {   # Define a sub-rede e a máscara de sub-rede
  range 192.168.1.10 192.168.1.100;         # Faixa de IPs disponíveis para atribuição
  option routers 192.168.1.1;                # Define o endereço IP do gateway
  option domain-name-servers 8.8.8.8;        # Define os servidores DNS
}
EOL
service isc-dhcp-server start   # Inicia o serviço DHCP
