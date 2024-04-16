#!/bin/bash

# Set the threshold for certificate expiration to 7 days in seconds
threshold=604800

# Get the expiry date of the Kubernetes cluster certificate
expiry_date=$(openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate | awk -F '=' '{print $2}')

# Convert the expiry date to Unix timestamp
expiry_timestamp=$(date -d "$expiry_date" +%s)

# Get the current Unix timestamp
current_timestamp=$(date +%s)

# Calculate the number of seconds until the certificate expires
time_until_expiry=$((expiry_timestamp - current_timestamp))

# If the certificate will expire within the threshold of 7 days, renew it
if [ "$time_until_expiry" -lt "$threshold" ]; then

cp -rp /etc/kubernetes /etc/kubernetes-backup-$(date +"%Y-%m-%d_%H-%M-%S")
kubeadm alpha certs renew all

docker ps | grep kube-apiserver | cut -d" " -f1 && docker rm -f $(docker ps | grep kube-apiserver | cut -d" " -f1 | xargs) && sleep 5 && docker ps | grep kube-apiserver
docker ps | grep kube-controller-manager | cut -d" " -f1 && docker rm -f $(docker ps | grep kube-controller-manager | cut -d" " -f1 | xargs) && sleep 5 && docker ps | grep kube-controller-manager
docker ps | grep kube-scheduler | cut -d" " -f1 && docker rm -f $(docker ps | grep kube-scheduler | cut -d" " -f1 | xargs) && sleep 5 && docker ps | grep kube-scheduler
docker ps | grep etcd | cut -d" " -f1 && docker rm -f $(docker ps | grep etcd | cut -d" " -f1 | xargs) && sleep 5 && docker ps | grep etcd


fi
