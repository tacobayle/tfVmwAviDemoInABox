resource "random_string" "ubuntu_password" {
  length           = 12
  special          = true
  min_lower        = 3
  min_upper        = 3
  min_numeric      = 3
  min_special      = 3
  override_special = "%$&*_"
}

data "template_file" "network" {
  count            = (var.dhcp == false ? length(var.ubuntu_ip4_addresses) : 0)
  template = file("templates/network.template")
  vars = {
    if_name = var.ubuntu.if_name
    ip4 = var.ubuntu_ip4_addresses[count.index]
    gw4 = var.gateway4
    dns = var.nameservers
  }
}

data "template_file" "ubuntu_userdata_static" {
  template = file("${path.module}/userdata/ubuntu_static.userdata")
  count            = (var.dhcp == false ? length(var.ubuntu_ip4_addresses) : 0)
  vars = {
    password      = var.ubuntu_password == null ? random_string.ubuntu_password.result : var.ubuntu_password
    pubkey        = chomp(tls_private_key.ssh.public_key_openssh)
    netplanFile = var.ubuntu.netplanFile
    hostname = "${var.ubuntu.basename}${random_string.ubuntu_name_id_static[count.index].result}"
    network_config  = base64encode(data.template_file.network[count.index].rendered)
  }
}

resource "random_string" "ubuntu_name_id" {
  count            = var.ubuntu.count
  length           = 8
  special          = true
  min_lower        = 8
}

resource "random_string" "ubuntu_name_id_static" {
  count            = (var.dhcp == false ? length(var.ubuntu_ip4_addresses) : 0)
  length           = 8
  special          = true
  min_lower        = 8
}

resource "vsphere_virtual_machine" "ubuntu_static" {
  count            = (var.dhcp == false ? length(var.ubuntu_ip4_addresses) : 0)
  name             = "${var.ubuntu.basename}${random_string.ubuntu_name_id_static[count.index].result}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  network_interface {
                      network_id = data.vsphere_network.network.id
  }

  num_cpus = var.ubuntu.cpu
  memory = var.ubuntu.memory
  wait_for_guest_net_routable = var.ubuntu.wait_for_guest_net_routable
  guest_id = "ubuntu64Guest"

  disk {
    size             = var.ubuntu.disk
    label            = "${var.ubuntu.basename}.lab_vmdk"
    thin_provisioned = true
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = vsphere_content_library_item.file.id
  }

  vapp {
    properties = {
     hostname    = "${var.ubuntu.basename}${random_string.ubuntu_name_id_static[count.index].result}"
//     password    = var.ubuntu.password
     public-keys = chomp(tls_private_key.ssh.public_key_openssh)
     user-data   = base64encode(data.template_file.ubuntu_userdata_static[count.index].rendered)
   }
 }

  connection {
   host        = split("/", var.ubuntu_ip4_addresses[count.index])[0]
   type        = "ssh"
   agent       = false
   user        = "ubuntu"
   private_key = tls_private_key.ssh.private_key_pem
  }

  provisioner "remote-exec" {
   inline      = [
     "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
   ]
  }
}

data "template_file" "ubuntu_userdata_dhcp" {
  template = file("${path.module}/userdata/ubuntu_dhcp.userdata")
  count            = (var.dhcp == true ? 1 : 0)
  vars = {
    password      = var.ubuntu_password == null ? random_string.ubuntu_password.result : var.ubuntu_password
    pubkey        = chomp(tls_private_key.ssh.public_key_openssh)
    hostname = "${var.ubuntu.basename}${random_string.ubuntu_name_id[count.index].result}"
    username = var.ubuntu.username
    docker_registry_username = var.docker_registry_username
    docker_registry_password = var.docker_registry_password
    avi_version = var.avi_version
    ansible_version = var.ansible_version
  }
}

resource "vsphere_virtual_machine" "ubuntu_dhcp" {
  count            = (var.dhcp == true ? var.ubuntu.count : 0)
  name             = "${var.ubuntu.basename}${random_string.ubuntu_name_id[count.index].result}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  network_interface {
    network_id = data.vsphere_network.network.id
  }

  num_cpus = var.ubuntu.cpu
  memory = var.ubuntu.memory
  wait_for_guest_net_routable = var.ubuntu.wait_for_guest_net_routable
  guest_id = "ubuntu64Guest"

  disk {
    size             = var.ubuntu.disk
    label            = "${var.ubuntu.basename}.lab_vmdk"
    thin_provisioned = true
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = vsphere_content_library_item.file.id
  }

  vapp {
    properties = {
      hostname    = "${var.ubuntu.basename}${random_string.ubuntu_name_id[count.index].result}"
//      password    = var.ubuntu.password
      public-keys = chomp(tls_private_key.ssh.public_key_openssh)
      user-data   = base64encode(data.template_file.ubuntu_userdata_dhcp[0].rendered)
    }
  }

  connection {
    host        = self.default_ip_address
    type        = "ssh"
    agent       = false
    user        = "ubuntu"
    private_key = tls_private_key.ssh.private_key_pem
  }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }
}