vsphere_password = "changeme"
vsphere_server   = "vcsa.mydomain.com"

cluster       = "vmware"
datacenter    = "cluster"
vm_folder     = "vms"
resource_pool = "harbor"
network       = "VM Network"
datastore     = "LUN01"

# Set HTTP proxy configuration (uncomment to enable proxy support).
#http_proxy_host = "192.168.0.1"
#http_proxy_port = 8080

harbor_hostname       = "harbor.local"
harbor_admin_password = "changeme"

# Run these commands to generate a self-signed TLS certificate:
# $ HARBOR_HOSTNAME=harbor.local
# $ openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout tls.key -out tls.crt -extensions san -config <(echo "[req]"; echo distinguished_name=req; echo "[san]"; echo subjectAltName=DNS:$HARBOR_HOSTNAME,DNS:charts.$HARBOR_HOSTNAME) -subj "/CN=$HARBOR_HOSTNAME"
harbor_tls_cert_file = "tls.crt"
harbor_tls_key_file  = "tls.key"
