# Variável para armazenar o nome de usuário da sua sessão Linux.
variable "username" {
  type        = string
  description = "Your linux session username"  # Descrição da variável
}

# Variável para armazenar o caminho para a sua chave privada.
variable "private_key_path" {
  type        = string
  description = "Path to your private key (ex: /home/your-user/.ssh/id_rsa)"  # Descrição da variável
}

# Variável para armazenar o caminho para a sua chave pública.
variable "public_key_path" {
  type        = string
  description = "Path to your public key (ex: /home/your-user/.ssh/id_rsa.pub)"  # Descrição da variável
}

# Variável para armazenar o endereço IP da sua máquina Ansible.
variable "ansible_host_ip" {
  type        = string
  description = "IP address of your Ansible VM (ex: 192.168.0.70)"  # Descrição da variável
}

# Variável para armazenar o endereço IP do seu host Proxmox.
variable "proxmox_host_ip" {
  type        = string
  description = "IP address of your Proxmox host (ex: 192.168.0.10)"  # Descrição da variável
}

# Variável para armazenar o endereço IP que você deseja para o seu mestre Kubernetes.
variable "k8s_master_ip" {
  type        = string
  description = "IP address you want for your kubernetes master (ex: 192.168.0.60)"  # Descrição da variável
}

# Variável para armazenar o nome do pool de armazenamento que você deseja usar para armazenar o disco da VM.
variable "storage_pool_name" {
  type        = string
  description = "Name of the storage pool you want to use to store the VM disk"  # Descrição da variável
}

# Variável para armazenar o endereço IP do gateway da sua sub-rede.
variable "subnet_gw" {
  type        = string
  description = "IP address of your subnet gateway (ex: 192.168.0.1)"  # Descrição da variável
}

# Variável para armazenar a máscara de sub-rede que você deseja usar no formato CIDR.
variable "subnet_mask" {
  type        = string
  description = "Subnet mask you want to use in CIDR format (ex: /24)"  # Descrição da variável
}

# Variável para armazenar o nome do seu nó PVE.
variable "pve_node_name" {
  type        = string
  description = "Name of your PVE node name (ex: proxmox)"  # Descrição da variável
}
