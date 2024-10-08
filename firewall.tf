// Configuração do firewall do Proxmox com Terraform
provider "proxmox" {
  pm_api_url   = "https://sua-url-do-proxmox"
  pm_password  = "*******"
  pm_user      = "*****"
  pm_insecure  = true // Ajuste conforme necessário
}

resource "proxmox_vm_qemu" "example" {
  name       = "testvm"
  vmid       = 100
  os_type    = "l26" // ou "windows" conforme necessário
  agent      = 1 // Ativar agente se necessário
  bios       = "seabios"
  scsihw     = "virtio-scsi-pci"
  balloon    = 0
  kvm        = 1
  memory     = 512
  sockets    = 1
  cores      = 1
  cpu        = "host"
  numa       = 0
  network {
    model    = "virtio"
    bridge   = "vmbr0"
  }
  ide0       = "local:iso/your_os_image.iso,media=cdrom"
  disk {
    storage  = "local"
    size     = 10G
    format   = "qcow2"
  }
  on_shutdown = "destroy"
}

resource "proxmox_firewall_group" "example" {
  name       = "testgroup"
  comment    = "Test firewall group"
  // Outras configurações conforme necessário
}

resource "proxmox_firewall_ipset" "example" {
  name       = "testipset"
  comment    = "Test IP set"
  // Outras configurações conforme necessário
}

resource "proxmox_firewall_rule" "example" {
  name       = "testrule"
  comment    = "Test firewall rule" 
  // Outras configurações conforme necessário
}
