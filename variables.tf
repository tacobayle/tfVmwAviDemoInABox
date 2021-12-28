variable "vsphere_username" {}
variable "vsphere_password" {}
variable "ubuntu_password" {
  default = null
}

variable "docker_registry_username" {
  sensitive = true
}

variable "docker_registry_password" {
  sensitive = true
}

variable "ansible_version" {
  default = "2.10.7"
}

variable "vsphere_server" {
  default = "wdc-06-vc12.oc.vmware.com"
}

variable "vcenter_dc" {
  default = "wdc-06-vc12"
}

variable "vcenter_cluster" {
  default = "wdc-06-vc12c01"
}

variable "vcenter_datastore" {
  default = "wdc-06-vc12c01-vsan"
}

variable "vcenter_network" {
  default = "vxw-dvs-34-virtualwire-3-sid-6120002-wdc-06-vc12-avi-mgmt"
}

variable "ubuntu_ip4_address" {
  default = "10.206.112.56/22"
}

variable "gateway4" {
  default = "10.206.112.1"
}

variable "nameservers" {
  default = "10.206.8.130, 10.206.8.130, 10.206.8.131"
}

variable "avi_version" {
  default = "21.1.2-9124-20211013.191102"
}

variable "ssh_key" {
  type = map
  default = {
    algorithm            = "RSA"
    rsa_bits             = "4096"
    private_key_name = "ssh_private_key_tf_ubuntu"
    file_permission      = "0600"
  }
}

variable "dhcp" {
  default = true
}

variable "content_library" {
  default = {
    basename = "content_library_tf_"
    source_url = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.ova"
  }
}

variable "ubuntu" {
  type = map
  default = {
    basename = "avi-in-a-box-tf-"
    count = 1
    username = "ubuntu"
    cpu = 24
    if_name = "ens192"
    memory = 65536
    disk = 96
    wait_for_guest_net_routable = "false"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
  }
}