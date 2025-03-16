# Define uma máquina virtual Proxmox chamada "c1-cp1" para o nó de controle do cluster Kubernetes.
resource "proxmox_vm_qemu" "c1-cp1" {
    name                      = "c1-cp1"                                   # Nome da máquina virtual
    boot                      = "order=virtio0"                            # Ordem de inicialização
    clone                     = "template-ubuntu-22.04"                    # Template a ser clonado
    full_clone	              = true                                      # Clonagem completa
    target_node               = var.pve_node_name                          # Nó alvo onde a VM será criada
    scsihw                    = "virtio-scsi-pci"                          # Controlador SCSI
    cpu                       = "kvm64"                                    # Tipo de CPU
    agent                     = 1                                          # Agente ativado
    sockets                   = 1                                          # Número de sockets
    cores                     = 2                                          # Número de núcleos
    memory                    = 3072                                       # Quantidade de memória (em MB)
    ci_wait                   = 0                                          # Tempo de espera para configuração inicial
    ciuser                    = var.username                              # Nome de usuário para configuração inicial
    cipassword                = var.username                              # Senha para configuração inicial
    ipconfig0                 = "ip=${var.k8s_master_ip}${var.subnet_mask},gw=${var.subnet_gw}"  # Configuração de IP
    sshkeys                   = file(var.public_key_path)                  # Chaves SSH

    network {
        bridge    = "vmbr1"                                              # Ponte de rede
        model     = "e1000"                                              # Modelo de adaptador de rede
        firewall  = false                                                 # Firewall desativado
        link_down = false                                                 # Link de rede ativo
    }
}

# Define duas máquinas virtuais Proxmox para os nós de trabalho do cluster Kubernetes.
resource "proxmox_vm_qemu" "c1-workers" {
    count                     = 2                                          # Número de instâncias a serem criadas
    name                      = "c1-node${count.index+1}"                  # Nome da máquina virtual com índice
    boot                      = "order=virtio0"                            # Ordem de inicialização
    clone                     = "template-ubuntu-22.04"                    # Template a ser clonado
    target_node               = var.pve_node_name                          # Nó alvo onde a VM será criada
    scsihw                    = "virtio-scsi-pci"                          # Controlador SCSI
    cpu                       = "host"                                     # CPU do hospedeiro
    agent                     = 1                                          # Agente ativado
    sockets                   = 1                                          # Número de sockets
    cores                     = 2                                          # Número de núcleos
    memory                    = 3072                                       # Quantidade de memória (em MB)
    ci_wait                   = 0                                          # Tempo de espera para configuração inicial
    ciuser                    = var.username                              # Nome de usuário para configuração inicial
    cipassword                = var.username                              # Senha para configuração inicial
    ipconfig0                 = "ip=192.168.1.${count.index+10}${var.subnet_mask},gw=${var.subnet_gw}"  # Configuração de IP
    sshkeys                   = file(var.public_key_path)                  # Chaves SSH

    network {
        bridge    = "vmbr1"                                              # Ponte de rede
        model     = "e1000"                                              # Modelo de adaptador de rede
        firewall  = false                                                 # Firewall desativado
        link_down = false                                                 # Link de rede ativo
    }

    depends_on = [ proxmox_vm_qemu.c1-cp1 ]                               # Depende da criação da máquina "c1-cp1"
}

# Gera um arquivo de inventário do Ansible com os IPs das máquinas virtuais.
resource "local_file" "ansible_inventory" {
    content = templatefile("./templates/inventory.tftpl",
        {
            master_ip = proxmox_vm_qemu.c1-cp1.default_ipv4_address      # IP do nó de controle
            worker_ip = proxmox_vm_qemu.c1-workers[*].default_ipv4_address  # IPs dos nós de trabalho
        }
    )

    filename = "./templates/inventory"                                     # Nome do arquivo de inventário
    depends_on = [ proxmox_vm_qemu.c1-workers, proxmox_vm_qemu.c1-cp1 ]    # Depende da criação das VMs
}

# Gera um arquivo de configuração do Ansible com o nome de usuário configurado anteriormente.
resource "local_file" "ansible_config" {
    content = templatefile("./templates/ansible.cfg.tftpl",
        {
            username = var.username                                      # Nome de usuário para o Ansible
        }
    )

    filename = "./templates/ansible.cfg"                                  # Nome do arquivo de configuração do Ansible
    depends_on = [ proxmox_vm_qemu.c1-workers, proxmox_vm_qemu.c1-cp1 ]    # Depende da criação das VMs
}

# Define uma máquina virtual Proxmox para o servidor Ansible.
resource "proxmox_vm_qemu" "c1-ansible" {
    name                      = "c1-ansible"                              # Nome da máquina virtual
    boot                      = "order=virtio0"                            # Ordem de inicialização
    clone                     = "template-ubuntu-22.04"                    # Template a ser clonado
    target_node               = var.pve_node_name                          # Nó alvo onde a VM será criada
    scsihw                    = "virtio-scsi-pci"                          # Controlador SCSI
    cpu                       = "host"                                     # CPU do hospedeiro
    agent                     = 1                                          # Agente ativado
    sockets                   = 1                                          # Número de sockets
    cores                     = 2                                          # Número de núcleos
    memory                    = 3072                                       # Quantidade de memória (em MB)
    ci_wait                   = 0                                          # Tempo de espera para configuração inicial
    ciuser                    = var.username                              # Nome de usuário para configuração inicial
    cipassword                = var.username                              # Senha para configuração inicial
    ipconfig0                 = "ip=${var.ansible_host_ip}${var.subnet_mask},gw=${var.subnet_gw}"  # Configuração de IP
    sshkeys                   = file(var.public_key_path)                  # Chaves SSH

    network {
        bridge    = "vmbr1"                                              # Ponte de rede
        model     = "e1000"                                              # Modelo de adaptador de rede
        firewall  = false                                                 # Firewall desativado
        link_down = false                                                 # Link de rede ativo
    }

    connection {
        type        = "ssh"                                               # Tipo de conexão SSH
        host        = var.ansible_host_ip                                 # Host para conexão SSH
        user        = var.username                                      # Usuário para conexão SSH
        password    = var.username                                      # Senha para conexão SSH
        private_key = file(var.private_key_path)   
        public key  = file(var.public_key_path)                       # Chave publica para conexão SSH
    }

    # Copia a chave SSH para a máquina virtual
    provisioner "local-exec" {
        command = "scp -qo StrictHostKeyChecking=no -i ${var.private_key_path} ${var.private_key_path} ${var.username}@${var.ansible_host_ip}:/home/${var.username}/.ssh"
    }

    # Copia o diretório de templates Ansible para a máquina virtual
    provisioner "local-exec" {
        command = "scp -qo StrictHostKeyChecking=no -i ${var.private_key_path} -r ./templates ${var.username}@${var.ansible_host_ip}:/home/${var.username}"
    }

    # Executa comandos remotos para configurar o Ansible
    provisioner "remote-exec" {
        inline = [
            "sudo chmod 0600 /home/${var.username}/.ssh/id_rsa",          # Define permissões para a chave SSH
            "sudo apt-add-repository ppa:ansible/ansible -y",             # Adiciona o repositório do Ansible
            "sudo apt update",                                            # Atualiza os pacotes
            "nohup sudo apt install ansible -y",                          # Instala o Ansible
            "sudo mkdir /etc/ansible",                                    # Cria o diretório de configuração do Ansible
            "sudo cp /home/${var.username}/templates/ansible.cfg /etc/ansible",  # Copia o arquivo de configuração do Ansible
            "ansible-playbook /home/${var.username}/templates/playbook.yml -i /home/${var.username}/templates/inventory",  # Executa o playbook do Ansible
        ]
        on_failure = continue                                             # Continua mesmo se houver falhas
    }

    depends_on = [ local_file.ansible_config, local_file.ansible_inventory ]  # Depende da criação dos arquivos de configuração e inventário do Ansible
}
