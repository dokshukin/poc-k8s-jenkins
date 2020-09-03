# poc-k8s-jenkins
Proof of Concept K8S and preconfigured Jenkins installation with terraform and ansible.  

The goal of that repo is to launch CI/CD infrastructure in Kubernetes with minimal manual efforts.
> Warning: That is `proof of concept` project for test purposes only! Don't use it in production!

## Requirements
  - ansible >= 2.9
  - terraform >= 0.13
  - helm >= 3
  - kubectl
  - access to Digital Ocean
  - generated ssh key pair + uploaded pub key in DigitalOcean
  

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
git clone https://github.com/dokshukin/poc-k8s-jenkins.git
cd poc-k8s-jenkins/terraform-digital-ocean/
```
If your pub key doesn't match default value, please create `terraform.tfvars` file with content:  
`pub_key = "/home/user/.ssh/your-key.pub"`

Run:
```
terrafrom init
terrafrom apply
```
Terraform will create 3 servers for Kubernetes, some firewall rules and will save output into ansible inventory file at `../ansible/inventories/kube_nodes`.


### Set up Kubernetes+CI/CD with Ansible
Now we have 3 servers (droplets) running in Digital Ocean.

#### Ansible

> You have to wait 2-3 minutes after creating droplets with terraform to use apt.

Let's spin up our service:
```
ansible-playbook playbook.yml
```
When ansible will finish its job (approx. 5 min) it will print kubernetes config. For example:
```
TASK [print-kube-config : put content into your ~/.kube/config] ***********************************************************************************
Pausing for 1 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
[print-kube-config : put content into your ~/.kube/config]
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ===
    server: https://IP.ADD.RE.SS:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data:  ==
    client-key-data:  ===
```
You'll need the key to connect to cluster and to save in Jenkins secrets.
The easiest way is to save output YAML content of  <YOUR_KUBERNETES_CONFIG> in your `~/.kube/config`

Check kubernets nodes connected:
```
kubectl get no
NAME            STATUS   ROLES    AGE     VERSION
ny-k8s-node01   Ready    master   3m54s   v1.17.11
ny-k8s-node02   Ready    <none>   3m31s   v1.17.11
ny-k8s-node03   Ready    <none>   3m31s   v1.17.11
```

### Helm
Go to helm directory.
```
cd ../helm
```
Modify values.yml with your secrets:
`master.adminPassword = `

and section with
```
  JCasC:
      secrets: |
        credentials.system.domainCredentials:
                - credentials:
                    - usernamePassword:
                        username: DOCKERHUB_USER
                        password: DOCKERHUB_TOKEN
```

Run to helm release:
```
bash run.sh
```



#### Last manual actions
Jenkins is running, but without defined secrets it might fail on the first pipelines during deploy process.  
So we need to add a kubernetes secrets in Jenkins WEB UI.

Correct secret IDs is:
  * k8s-config

1. Open Jenkins web UI http://IP.ADD.RE.SS:30000/credentials/
2. Click on "global"
3. In Left Menu click "Add Credentials"
4. Fill and save docker secrets:
  * Kind: Kubernetes configuration (kubeconfig)
  * Scope: Global (Jenkins, nodes, items, all chield items, etc.)
  * ID: k8s-config (correct name is very important here)
  * Kubeconfig -> Enter directly
  * Paste into content <YOUR_KUBERNETES_CONFIG>
5. Save. Now we can relaunch job with all steps

#### Deploy
Now we can proceed to the first deploy.
Go to the job pipeline and click "Build Now".
> pipeline should build docker image, push it into DockerHub registry (username is taken from secret) and deploy to current K8s cluster.
You can see tiny web application running on http://IP.ADD.RE.SS:30001 (same IP as Jenkins WEB UI)

Push some changes into the repo(s) provided by `ansible/group_vars/kube_nodes/jenkins.yml:jenkins_k8s_pipelines` and during a minute new pipeline should be triggered and, in a case of success, new application version will be deployed.

## Disclaimer
The project is Proof-Of-Concept only.

Security issues:
1. No LAN. All K8s servers are using public NICs and IPs for communication.
2. No kubernetes ingress/load-balancers, hostnames and HTTPS/SSL
3. Only one node of 3 is a master node.
4. There is only one kubernetes admin service account used for all purposes.
5. Terraform state is local file.
6. Helm secrets are not included from sources, sorry.
