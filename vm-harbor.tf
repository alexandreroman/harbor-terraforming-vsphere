# Generate configuration file.
resource "local_file" "env_file" {
    content = templatefile("env.tpl", {
      http_proxy_host       = var.http_proxy_host,
      http_proxy_port       = var.http_proxy_port,
      harbor_hostname       = var.harbor_hostname,
      harbor_admin_password = var.harbor_admin_password
    })
    filename        = "env"
    file_permission = "0644"
}

# Create a VM which will host Harbor.
resource "vsphere_virtual_machine" "harbor" {
  name             = "harbor"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  # Older versions of VMware tools do not return an IP address:
  # get guest IP address instead.
  wait_for_guest_net_timeout = -1
  wait_for_guest_ip_timeout  = 2

  num_cpus = 2
  memory   = 8192
  guest_id = "ubuntu64Guest"
  folder   = vsphere_folder.vm_folder.path

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    thin_provisioned = true
    size             = 60
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu_template.id

    # Do not include a "customize" section here:
    # this feature is broken with current Ubuntu Cloudimg templates.
  }

  # A CDROM device is required in order to inject configuration properties.
  cdrom {
    client_device = true
  }

  vapp {
    properties = {
      "instance-id" = "harbor"
      "hostname"    = "harbor"
      
      # Use our own public SSH key to connect to the VM.
      "public-keys" = file("~/.ssh/id_rsa.pub")
    }
  }

  connection {
      host        = vsphere_virtual_machine.harbor.default_ip_address
      timeout     = "30s"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
  }
  provisioner "file" {
    # Copy configuration file.
    source      = "env"
    destination = "/home/ubuntu/.env"
  }
  provisioner "file" {
    # Copy install scripts.
    source      = "setup-harbor.sh"
    destination = "/home/ubuntu/setup-harbor.sh"
  }
  provisioner "file" {
    # Copy TLS certificate.
    source      = var.harbor_tls_cert_file
    destination = "/home/ubuntu/tls-harbor.crt"
  }
  provisioner "file" {
    # Copy TLS key.
    source      = var.harbor_tls_key_file
    destination = "/home/ubuntu/tls-harbor.key"
  }
  provisioner "remote-exec" {
    # Run installation script.
    inline = [
      "echo ${vsphere_virtual_machine.harbor.default_ip_address} ${var.harbor_hostname} | sudo tee -a /etc/hosts",
      "chmod +x /home/ubuntu/setup-harbor.sh",
      "sh /home/ubuntu/setup-harbor.sh"
    ]
  }
}

output "harbor_ip_address" {
  value = vsphere_virtual_machine.harbor.default_ip_address
}
