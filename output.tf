//output "ubuntu_static_ips" {
//  value = var.dhcp == false ? var.ubuntu_ip4_addresses.* : null
//}

output "ubuntu_ip" {
  value = var.dhcp == true ? vsphere_virtual_machine.ubuntu[0].default_ip_address : split("/", var.ubuntu_ip4_address)[0]
}

output "ubuntu_username" {
  value = var.ubuntu.username
}

output "ubuntu_password" {
  value = var.ubuntu_password == null ? random_string.ubuntu_password.result : var.ubuntu_password
}

output "avi_ip" {
  value = var.dhcp == true ? vsphere_virtual_machine.ubuntu[0].default_ip_address : split("/", var.ubuntu_ip4_address)[0]
}

output "avi_username" {
  value = "admin"
}

output "avi_password" {
  value = var.ubuntu_password == null ? random_string.ubuntu_password.result : var.ubuntu_password
}

output "rdp_server" {
  value = var.dhcp == true ? "${vsphere_virtual_machine.ubuntu[0].default_ip_address}:3389" : "${split("/", var.ubuntu_ip4_address)[0]}:3389"
}

output "rdp_username" {
  value = "admin"
}

output "rdp_password" {
  value = "AviDemo1!"
}

output "ssh_private_key_path" {
  value = "~/.ssh/${var.ssh_key.private_key_name}.pem"
}

output "ssh_connect_to_ubuntu_VM" {
  value = var.dhcp == true ? "ssh -i ~/.ssh/${var.ssh_key.private_key_name}.pem -o StrictHostKeyChecking=no ubuntu@${vsphere_virtual_machine.ubuntu[0].default_ip_address}" : "ssh -i ~/.ssh/${var.ssh_key.private_key_name}.pem -o StrictHostKeyChecking=no ubuntu@${split("/", var.ubuntu_ip4_address)[0]}"
}

