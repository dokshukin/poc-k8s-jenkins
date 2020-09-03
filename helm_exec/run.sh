#!/bin/bash -

set -o nounset                              # Treat unset variables as an error

helm repo add jenkinsci https://charts.jenkins.io
helm repo update

helm upgrade --install jenkins-master jenkinsci/jenkins -f values.yaml
