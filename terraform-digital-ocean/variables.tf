variable "region" {
  type    = string
  default = "fra1"
}

variable "image" {
  type    = string
  default = "ubuntu-20-04-x64"
}

variable "network_range" {
  type    = string
  default = "10.255.255.0/24"
}

variable "network_name" {
  type    = string
  default = "k8s-subnet"
}

variable "vm_size" {
  type    = string
  // curl -sX GET -H 'Content-Type: application/json' -H "Authorization: Bearer $DIGITALOCEAN_TOKEN"  "https://api.digitalocean.com/v2/sizes" | jq .sizes[].slug
  // default = "s-1vcpu-1gb"
  default = "s-2vcpu-4gb"
}

// Please redefine it in terraform.tfvars (and please use full path on MacOS)
// example:
// pub_key = "/home/user/.ssh/my_key.pub"
variable "pub_key" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}
