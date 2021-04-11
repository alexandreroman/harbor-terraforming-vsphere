variable "vsphere_user" {
  type    = string
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  type = string
}

variable "vsphere_server" {
  type = string
}

variable "datacenter" {
  type    = string
  default = "Datacenter"
}

variable "cluster" {
  type    = string
  default = "Cluster"
}

variable "datastore" {
  type    = string
  default = "LUN01"
}

variable "vm_folder" {
  type    = string
  default = "tkg"
}

variable "resource_pool" {
  type    = string
  default = "platform"
}

variable "network" {
  type    = string
  default = "VM Network"
}

variable "ubuntu_template" {
  type    = string
  default = "bionic-server-cloudimg-amd64"
}

variable "http_proxy_host" {
  type    = string
  default = ""
}

variable "http_proxy_port" {
  type    = number
  default = 8080
}

variable "harbor_hostname" {
  type    = string
}

variable "harbor_admin_password" {
  type    = string
  default = "changeme"
}

variable "harbor_tls_cert_file" {
  type    = string
  default = "tls.crt"
}

variable "harbor_tls_key_file" {
  type    = string
  default = "tls.key"
}
