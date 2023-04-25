#!/bin/bash
source ./setEnv.sh

mainMenu () {
  clear
  echo "Welcome to DIH Builder on Azure!"
  echo "--------------------------------"
  echo
  echo Subscription: $SUBSCRIPTION_NAME
  echo Client ID: $LOGGEDIN_USER
  echo Reasource Group: $REASOURCE_GROUP
  echo
  echo "1. AKS Management"
  echo "2. DIH Management"
  echo "E. Exit"
  echo 
  read -p ">> " choice

  case "$choice" in
  
      1)  aksMenu
          ;;
      
      2)  dihMenu
          ;;
          
      [eE]) exit
          ;;

      *) mainMenu
          ;;
  esac
  
}

aksMenu () {
  echo "AKS management"
  echo "--------------"
  echo
  echo "1. Set a current AKS cluster (update kubeconfig)"
  echo "2. Create a new AKS cluster"
  echo "3. Delete an AKS Cluster"
  echo "4. Create an Jumper VM"
  echo "B. Back to Main menu."
  echo "E. Exit"
  echo 
  read -p ">> " choice

  case "$choice" in
      1) chooseExistingAKS  
         aksMenu  
          ;;
      
      2) createAKScluster
         aksMenu       
          ;;

      3) destroyAKScluster
         aksMenu
          ;;
      4) createJumper
         aksMenu
          ;;

      [Bb]) mainMenu
          ;;

      [eE]) exit
          ;;

      *) aksMenu
          ;;
  esac
}

dihMenu () {
  echo "DIH management"
  echo "--------------"
  echo
  echo "1. Install DIH umbrella"
  echo "2. Uninstall DIH umbrella"
  echo "B. Back to Main menu."
  echo "E. Exit"
  echo 
  read -p ">> " choice

  case "$choice" in
      1) installDIH  
         dihMenu  
          ;;

      2) uninstallDIH  
         dihMenu  
          ;;
      
      [Bb]) mainMenu
          ;;

      [eE]) exit
          ;;

      *) dihMenu
          ;;
  esac

}
createResourceGroup () {
  # Create a reasource group
  az group create --name $REASOURCE_GROUP --location $LOCATION
}

createJumper () {
  # Create a Jumper VM
  if [[ -z $CLUSTER_NAME ]]
  then
    read -p "Please enter a Jumper description ( 'jumper-<description> ): " CLUSTER_NAME
  fi  
  echo "Create a Jumper VM on azure [ jumper-$CLUSTER_NAME ]..."
  az vm create \
  -n jumper-$CLUSTER_NAME \
  -g $REASOURCE_GROUP \
  --image $JUMPER_IMAGE \
  --custom-data $JUMPER_USERDATA \
  --ssh-key-value $JUMPER_PUBLIC_KEY \
  --public-ip-sku Standard \
  --nic-delete-option delete \
  --os-disk-delete-option delete \
  --admin-username centos \
  --tags Owner=$owner Project=$project $default_tags \
  --size $JUMPER_SIZE
    
}

createAKScluster () {
  echo
  read -p "Cluster Name: " CLUSTER_NAME
  read -p "Project: " TAG_PROJECT
  read -p "Owner: " TAG_OWNER
  read -p "Would you like to create a jumper vm for this AKS? [y/n] " CREATE_JUMPER

  # Create an AKS cluster
  echo "Creating an AKS cluster [ $CLUSTER_NAME ]"
  az aks create \
  -g $REASOURCE_GROUP \
  -n $CLUSTER_NAME \
  --node-count $AKS_NODE_COUNT \
  --tags "Project=$TAG_PROJECT Owner=$TAG_OWNER gspolicy=$TAG_GSPOLICY" \
  --node-vm-size $AKS_VM_SIZE
  
  # Create a jumper if requested
  if [[ $CREATE_JUMPER =~ [yY](es)* ]]
  then
    echo createJumper
  fi
  
}

chooseExistingAKS () {
  echo "Fetching clusters ..."
  az aks list --resource-group $REASOURCE_GROUP
  echo 
  echo  "Enter the cluster name to set as the current context: (to the previous menu type B/b)"
  read -p ">> " CLUSTER_NAME
  if [[ $CLUSTER_NAME = "B" ]] || [[ $CLUSTER_NAME = "b" ]]
  then 
    return 0 
  fi
  if [[ $(az aks list -g gng-lab -o json --query "[?name=='$CLUSTER_NAME'] | length(@)") = 1 ]]
    then 
      updateKubeConfig
    else
      echo "$CLUSTER_NAME cluster does not exist"
      chooseExistingAKS
  fi
}

updateKubeConfig () {
  echo "Updating kube config file for [ $CLUSTER_NAME ] cluster ..."
  az account set --subscription $ARM_SUBSCRIPTION_ID
  az aks get-credentials --resource-group $REASOURCE_GROUP --name $CLUSTER_NAME
  echo "Current context: $(kubectl config current-context)"
}

loginAzureAccount () {
    echo "Login to azure ..."
  if [[ $(az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID) ]]
  then
    echo "Login succeeded."
    LOGGEDIN_USER=$(az account list --query "[?isDefault].user.name" -o tsv)
    SUBSCRIPTION_NAME=$(az account list --query "[?isDefault].name" -o tsv)
    
  else
    echo "Login failed, please make sure you set the correct ARM_CLIENT_ID ARM_CLIENT_SECRET ARM_TENANT_ID variables and try again."
    exit;
  fi
}

destroyAKScluster () {
  chooseExistingAKS
  if [[ $CLUSTER_NAME == "B" ]] || [[ $CLUSTER_NAME == "b" ]]
  then 
    return 0 
  fi
  az aks delete --name $CLUSTER_NAME --resource-group $REASOURCE_GROUP --no-wait
}

installDIH () {
  chooseExistingAKS
  if [[ $CLUSTER_NAME == "B" ]] || [[ $CLUSTER_NAME == "b" ]]
  then 
    return 0 
  fi
  read -p "Would you like to install the DIH umbrella with IIDR [y/n] " INSTALL_IIDR
  [[ $INSTALL_IIDR =~ [yY](es)* ]] && IIDR=true || IIDR=false
  echo "Deploying DIH umbrella ..."
  #  Add required secrets
  kubectl create secret docker-registry myregistrysecret --docker-server=https://index.docker.io/v1/ --docker-username=dihcustomers --docker-password=dckr_pat_NYcQySRyhRFZ6eUQAwLsYm314QA --docker-email=dih-customers@gigaspaces.com
  kubectl create secret generic datastore-credentials --from-literal=username='system' --from-literal=password='admin11'

  # helm repo add DIH
  helm repo add dih https://s3.amazonaws.com/resources.gigaspaces.com/helm-charts-dih
  helm repo update dih

  # Install ingress-controller
  installIngressController
  
  # Install DIH
    helm install dih dih/dih --version 16.3.0-rc3 --set global.iidrKafkaHost=$ingressIP,tags.iidr=$IIDR -f DIH/helm/dih-umbrella.yaml
}

uninstallDIH () {
  chooseExistingAKS
  read -p "Are you sure you want to uninstall DIH from $CLUSTER_NAME? [y/n]: " REMOVE_DIH
  if [[ $REMOVE_DIH =~ [yY](es)* ]]
  then
    read -p "Remove ingress-controller from $CLUSTER_NAME? [y/n]: " REMOVE_INGRESS
    if [[ $REMOVE_INGRESS =~ [yY](es)* ]]
    then
      echo "Removing the ingress-nginx ..."
      helm uninstall ingress-nginx
    fi
    echo "Removing the dih ..."
    helm uninstall dih
  fi 
  dihMenu
  
}
installIngressController () {
  # helm repo add DIH and ingress-controller
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update ingress-nginx

  # Install ingress-controller
  helm install ingress-nginx ingress-nginx/ingress-nginx -f DIH/helm/ingress-controller-tcp.yaml
  ingressIP=$(kubectl get svc ingress-nginx-controller -o json | jq -r .status.loadBalancer.ingress[].ip)
}
##### Main #####
clear
loginAzureAccount
mainMenu





