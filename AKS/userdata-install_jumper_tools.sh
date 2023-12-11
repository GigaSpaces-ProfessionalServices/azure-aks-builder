#!/bin/bash

# Install kubectl
echo "Installing kubectl ..."
curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm ./kubectl

# Install helm
echo "Installing helm ..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm ./get_helm.sh

# Install azure cli
echo "Installing azure cli ..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install vim, wget, unzip, git, maven, openjdk11, k9s
echo "Installing vim, wget, unzip, git, maven, openjdk11"
if [[ $(cat /etc/*-release |grep -i "ubuntu\|debian" |wc -l) > 0 ]];then 
  sudo apt-get install -y  openjdk-11-jdk wget unzip maven
  sudo snap install k9s --devmode

elif [[ $(cat /etc/*-release |grep -i "ubuntu\|debian" |wc -l) > 0 ]];then
  sudo yum install -y vim wget unzip maven java-11-openjdk-devel
  curl -sS https://webi.sh/k9s | sh

elif [[ $(uname) == "Darwin" ]];then
  brew brew install vim wget unzip maven openjdk@11 k9s

else
  echo "Unsupported Linux distribution, please install vim, wget, unzip, git, maven, openjdk11 manually."
fi

# Install k9s
echo "Installing k9s ..."
curl -sS https://webi.sh/k9s | sh
