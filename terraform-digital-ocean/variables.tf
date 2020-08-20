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
  // default = "s-1vcpu-1gb" // for testing purpose
  default = "s-2vcpu-4gb"  // curl -sX GET -H 'Content-Type: application/json' -H "Authorization: Bearer $DIGITALOCEAN_TOKEN"  "https://api.digitalocean.com/v2/sizes" | jq .sizes[].slug
}
