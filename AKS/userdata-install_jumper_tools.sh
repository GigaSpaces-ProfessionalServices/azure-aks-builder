#!/bin/bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo yum install -y yum-utils epel-release
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
sudo yum install -y wget vim unzip git azure-cli maven
wget https://s3.eu-west-1.amazonaws.com/shmulik.kaufman/bbw/jdk-11.0.17_linux-x64_bin.rpm
sudo rpm -ivh jdk-11.0.17_linux-x64_bin.rpm
rm -rf ./get_helm.sh jdk-11.0.17_linux-x64_bin.rpm kubectl
sudo -u centos curl -sS https://webinstall.dev/k9s | bash

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
yum install bash-completion -y
sudo yum install jq -y
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
echo 'alias k=kubectl' >> /home/centos/.bashrc
echo 'complete -o default -F __start_kubectl k' >> /home/centos/.bashrc

echo '
export ARM_CLIENT_ID=""
export ARM_CLIENT_SECRET=""
export ARM_SUBSCRIPTION_ID=""
export ARM_TENANT_ID=""
clear' >> /home/centos/.bashrc 

echo '
echo "
Welcome to the azure DIH Jumper
--------------------------------------
Installed tools:

# kubecl
# helm
# azure cli
# git
# k9s
# Auto-completion for Kubectl
# wget, vim, unzip
# maven
# jdk 11
--------------------------------------
"
' >> /home/centos/.bashrc

cd /home/centos
sudo -u centos git clone https://github.com/GigaSpaces-ProfessionalServices/azure-aks-builder.git