##### use environment variable for authentication
# generate token in personal account page and
# add to your ~/.bash_profile
# export DIGITALOCEAN_TOKEN=your_token


# Configure the DigitalOcean Provider
provider "digitalocean" {
}

# init server with preinstalled packages and predefined root password
variable "user_data_path" {
  default = "./cloud_init/user_data.yaml"
}
