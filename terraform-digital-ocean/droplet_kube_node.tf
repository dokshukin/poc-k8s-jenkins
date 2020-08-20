locals {
  // avoiding usage of "count" will allow wasily add and remove nodes from cluster (a-z, A-Z, 0-9, . and -)
  kube_nodes_names = [
    "ny-k8s-node02",
    "ny-k8s-node03",
  ]

  kube_nodes_tags = [
    "project_k8s",
    "kubenode",
    "ansible_group_kube_nodes",
  ]
}

resource "digitalocean_droplet" "kube_node_master" {
  name        = "ny-k8s-node01"
  image       = var.image
  region      = var.region
  size        = var.vm_size
  monitoring  = true
  user_data   = file(var.user_data_path)
  tags = concat(local.kube_nodes_tags, [ "ansible_var_kubernetes_role:master" ])
}

resource "digitalocean_droplet" "kube_node" {
  for_each    = toset(local.kube_nodes_names)
  name        = each.value
  image       = var.image
  region      = var.region
  size        = var.vm_size
  monitoring  = true
  user_data   = file(var.user_data_path)
  tags        = local.kube_nodes_tags
}
