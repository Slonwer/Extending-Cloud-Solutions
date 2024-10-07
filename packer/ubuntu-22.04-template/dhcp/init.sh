# Define a variável de ambiente LANG como "en_US.UTF-8"
# Isso define o idioma padrão do sistema para inglês, usando a codificação UTF-8
export LANG="en_US.UTF-8"

# Define a variável LC_ALL como "C"
# Isso força todas as configurações regionais a usarem a configuração "C", 
# que é a configuração padrão do sistema, independente de localizações.
export LC_ALL="C"

# Verifica se o comando "dhcpd" está disponível no sistema (usando 'type' para testar a presença do comando)
# O '>& /dev/null' redireciona a saída de erro e sucesso para o "nada", ou seja, não exibe nada no terminal.
if ! type "dhcpd" >& /dev/null; then
  # Se "dhcpd" não estiver instalado, instala o pacote "isc-dhcp-server"
  # O comando 'DEBIAN_FRONTEND=noninteractive' garante que a instalação seja não interativa (não pede confirmações ao usuário)
  # As opções 'Dpkg::Options::="--force-confdef"' forçam a aceitação das configurações padrão durante a instalação.
  /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install isc-dhcp-server
fi
