#!/bin/bash
# Install k8s-dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard

# Create a serviceaccount
kubectl apply -f /home/centos/azure-aks-builder/dashboard-admin.yaml

# Create a token
kubectl create token admin-user --duration=8760h > ~/k8s-dashboard.txt
