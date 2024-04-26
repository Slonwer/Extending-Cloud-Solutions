# Configuração do Terraform para definir o provedor e suas dependências.
terraform {
  # Declaração dos provedores necessários para o Terraform.
  required_providers {
    # Definição do provedor Proxmox e sua versão.
    proxmox = {
      source = "thegameprofi/proxmox"  # Fonte do provedor Proxmox
      version = "2.9.15"               # Versão específica do provedor
    }
  }
}

# Configuração do provedor Proxmox.
provider "proxmox" {
  # URL da API do Proxmox, utilizando a variável proxmox_host_ip.
  pm_api_url = "https://${var.proxmox_host_ip}:8006/api2/json"
}
