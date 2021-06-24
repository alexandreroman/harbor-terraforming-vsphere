terraform {
  required_providers {
    vsphere = "~> 2.0.1"
    local = "~> 2.1.0"
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}
