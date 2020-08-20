# poc-k8s-jenkins
Proof of Concept K8S and preconfigured Jenkins installation with terraform and ansible.  

The goal of that repo is to launch CI/CD infrastructure in Kubernetes with minimal manual efforts.
> Warning: That is `proof of concept` project for test purposes only! Don't use it in production!

## Requirements
  - ansible >= 2.9
  - terraform >= 0.13
  - sshpass (to allow first ansible play with password authentication)
  - access to Digital Ocean

## Guide

### Infrastructure

#### Get your Digital Ocaen token if you don't have one.

  * Link: [https://cloud.digitalocean.com/account/api/tokens]

  * "Personal access tokens" -> "Generate New Token" button.

  * Set environment variable DIGITALOCEAN_TOKEN in your shell
```
export DIGITALOCEAN_TOKEN=here-should-be-your-token
```

#### Create infrastructure with Terraform
```
cd ./terraform-digital-ocean
terrafrom init
terrafrom apply
```
Terraform will create 3 servers for Kubernetes, some firewall rules, and set to `root` user predefined password.


### Set up Kubernetes+CI/CD with Ansible
Now we have 3 servers (droplets) running in Digital Ocean.

#### Ansible
Add your user(s) and ssh key(s) in `ansible/group_vars/all/users.yml`
> alternatively add your keys in `terraform-digital-ocean/cloud_init/user_data.yaml` (not recommended, not tested)

The tiny dynamic inventory script was writtent to make ansible repatable on different environments.  
First time ansible should be played with root user to create other users:
```
cd ../ansible
ansible-playbook playbook.yml -t users -u root -k
```
There will appear prompt with request of password. Type it there, press ENTER.
> sshpass need be installed on your system to use `-k` flag with ansible

From now you can use your ssh user+key pair access servers and play ansible roles.
> You have to wait 2-3 minutes after creating droplets with terraform to use apt.

Let's spin up our service:
```
ansible-playbook playbook.yml
```
When ansible will finish its job it will print the URL to connect to Jenkins UI. For example:
```
TASK [jenkins-k8s : INFO MESSAGE] **********************************
ok: [68.183.216.2] =>
  msg: |-
    ================================================================
    Jenkins is running on http://68.183.216.2:30000
    ================================================================
```

#### Last manual actions
Jenkins is running, but without set up secrets it might fail first pipelines.  
So we need to add a couple of secrets in Jenkins WEB UI.

Correct secret IDs are:
  * docker-credentials
  * k8s-service-account

1. Open http://IP.ADD.RE.SS:30000/credentials/
2. Click on "Jenkins" down-arrow icon and click on "Add domain" in drop-down list.
3. Create a new domain with some test naming. Click "OK".
4. In Left Menu click "Add Credentials"
5. Fill and save docker secrets:
  * Kind: Username with password
  * Scope: Global (Jenkins, nodes, items, all chield items, etc.)
  * Username: <GET_USERNAME_FOR_DOCKERHUB>
  * Password: <GET_TOKEN_FOR_DOCKERHUB>
  * ID: docker-credentials (correct name is very important here)
  * Description: any description you want
6. Get kubernets admin service account (copy base64 ountput from master node):  
```ansible -b -m shell -a '[ -f /etc/kubernetes/admin.conf ] && cat /etc/kubernetes/admin.conf | base64' kube_nodes```
7. Click on left menu "Add Credentials"
8. Fill and save kubernetes secret:
  * Kind: Secret Text
  * Secret: paste base64 output here
  * ID: k8s-service-account (correct name is very important here)
  * Description: any description you want

#### Deploy
Now we can proceed to the first deploy.
Go to the job pipeline and click "Build Now".
> pipeline should build docker image, push it into docker registry (username is taken from secret) and deploy to current K8s cluster.
You can see tiny web application running on http://IP.ADD.RE.SS:30001 (same IP as Jenkins WEB UI)

Push some changes into the repo in provided by `ansible/group_vars/kube_nodes/jenkins.yml:jenkins_k8s_pipelines` and during a minute new pipeline should be triggered and, in a case of success, new application version will be deployed.

## Disclaimer
The project is Proof-Of-Concept only.

Security issues:
1. No LAN. All K8s servers are using public NICs and IPs for communication.
2. No Jenkins auth.
3. No kubernetes ingress/load-balancers, hostnames and HTTPS/SSL
4. Only one node of 3 is a master node.
5. There is a "local" storage located on a master k8s node mounted as PVC to keep Jenkins data.
6. There is only one kubernetes admnin service account used for all purposes.
7. Docker socket has RW permissions to allow jenkins user DinD usage.
8. Jenkins main config.yml is delivered from ansible teplate to guarantee cloud settings (instead of usage XML-edit)
9. Terraform state is local file.
