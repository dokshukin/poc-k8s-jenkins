locals {
  // avoiding usage of "count" will allow easily add and remove nodes from cluster (a-z, A-Z, 0-9, . and -)
  kube_nodes_names = {
    "ny-k8s-node01" = "kubernetes_role_master",
    "ny-k8s-node02" = "kubernetes_role_node",
    "ny-k8s-node03" = "kubernetes_role_node",
  }

  kube_nodes_tags = [
    "project_k8s",
    "kubenode",
  ]
}

// get user's ssh pub key MD5 fingerprint
data "external" "ssh_key_md5" {
  program = ["/bin/sh", "./handler_ssh.sh"]
  query = {
    pub_key = var.pub_key
  }
}

// create droplets
resource "digitalocean_droplet" "kube_node" {
  for_each   = local.kube_nodes_names
  name       = each.key
  image      = var.image
  region     = var.region
  size       = var.vm_size
  monitoring = true
  ssh_keys = [
    data.external.ssh_key_md5.result.ssh_md5
  ]
  tags = concat(
    local.kube_nodes_tags,
    [each.value],
  )
}

// generate ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile(
    "inventory.tmpl",
    {
      obj = digitalocean_droplet.kube_node
    }
  )
  filename = "../ansible/inventories/kube_nodes"
  file_permission = "0644"
}
