resource "digitalocean_firewall" "k8s_firewall" {
  name = "k8s-firewall"

  tags = [
    "project_k8s",
  ]

  // allow ICMP
  inbound_rule {
    protocol = "icmp"
    source_addresses = [
      "0.0.0.0/0",
    ]
  }
  outbound_rule {
    protocol = "icmp"
    destination_addresses = [
      "0.0.0.0/0",
    ]
  }

  // allow SSH (testing only)
  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    source_addresses = [
      "0.0.0.0/0",
    ]
  }
  inbound_rule {
    protocol   = "tcp"
    port_range = "80"
    source_addresses = [
      "0.0.0.0/0",
    ]
  }
  inbound_rule {
    protocol   = "tcp"
    port_range = "6443"
    source_addresses = [
      "0.0.0.0/0",
    ]
  }
  inbound_rule {
    protocol   = "tcp"
    port_range = "30000-32767"
    source_addresses = [
      "0.0.0.0/0",
    ]
  }

  // allow outgoing connections
  outbound_rule {
    protocol   = "tcp"
    port_range = "all"
    destination_addresses = [
      "0.0.0.0/0",
    ]
  }
  outbound_rule {
    protocol   = "udp"
    port_range = "all"
    destination_addresses = [
      "0.0.0.0/0",
    ]
  }
  outbound_rule {
    protocol = "icmp"
    destination_addresses = [
      "0.0.0.0/0",
    ]
  }

  # for internal communication
  inbound_rule {
    protocol   = "tcp"
    port_range = "1-65535"
    source_tags = [
      "project_k8s",
    ]
  }
  inbound_rule {
    protocol   = "udp"
    port_range = "1-65535"
    source_tags = [
      "project_k8s",
    ]
  }


}
