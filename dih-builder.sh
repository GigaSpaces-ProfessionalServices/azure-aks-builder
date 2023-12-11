#!/bin/bash
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd $SCRIPTPATH
source ./setEnv.sh

mainMenu () {
  clear
  echo "Welcome to DIH Builder on Azure!"
  echo "--------------------------------"
  echo Subscription: $SUBSCRIPTION_NAME
  echo Client ID: $LOGGEDIN_USER
  echo Resource Group: $RESOURCE_GROUP
  echo
  echo "## To change the above details, edit setEnv.sh and restart the dih-builder.sh ##"
  echo 
  echo Main
  echo ----
  echo "1. AKS Management"
  echo "2. DIH Management"
  echo "E. Exit"
  echo 
  read -p ">> " choice

  case "$choice" in
  
      1)  aksMenu
          ;;
      
      2)  chooseExistingAKS
          dihMenu
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
  echo "4. Create a Jumper VM"
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
      4) unset CLUSTER_NAME
         createJumper
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
  echo
  echo "DIH management [$CLUSTER_NAME]"
  echo "------------------------------"
  echo
  echo "1. Install DIH umbrella"
  echo "2. Uninstall DIH umbrella"
  echo "3. Install Oracle DB for demo"
  echo "4. Uninstall Oracle DB for demo"
  echo "5. Print ingress services/ports"
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
      
      3) installOracleDB
         dihMenu
          ;;
      
      4) uninstallOracleDB
         dihMenu
          ;;
      5) printIngressTCP
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
  az group create --name $RESOURCE_GROUP --location $LOCATION
}

createJumper () {
  # Create a Jumper VM
  if [[ -z $CLUSTER_NAME ]]
  then
    read -p "Please enter a Jumper Name: " CLUSTER_NAME
  fi  
  echo "Create a Jumper VM on azure [ $CLUSTER_NAME ]..."
  az vm create \
  -n $CLUSTER_NAME \
  -g $RESOURCE_GROUP \
  --image $JUMPER_IMAGE \
  --custom-data $JUMPER_USERDATA \
  --ssh-key-value $JUMPER_PUBLIC_KEY \
  --public-ip-sku Standard \
  --nic-delete-option delete \
  --os-disk-delete-option delete \
  --admin-username $JUMPER_ADMIN_USER \
  --tags Owner=$owner Project=$project $default_tags \
  --size $JUMPER_SIZE \
  --output table
  
    
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
  -g $RESOURCE_GROUP \
  -n $CLUSTER_NAME \
  --node-count $AKS_NODE_COUNT \
  --tags "Project=$TAG_PROJECT Owner=$TAG_OWNER gspolicy=$TAG_GSPOLICY" \
  --node-vm-size $AKS_VM_SIZE \
  --no-ssh-key \
  --zones 1 2 3 \
  --output table 
  updateKubeConfig

  # Create a jumper if requested
  if [[ $CREATE_JUMPER =~ [yY](es)* ]]
  then
    createJumper
  fi
  
}

chooseExistingAKS () {
  echo "Fetching clusters ..."
  az aks list --resource-group $RESOURCE_GROUP -o table
  echo 
  echo  "Enter the cluster name to set as the current context: (to the previous menu type B/b)"
  read -p ">> " CLUSTER_NAME
  if [[ $CLUSTER_NAME = "B" ]] || [[ $CLUSTER_NAME = "b" ]]
  then 
    return 0 
  fi
  if [[ $(az aks list -g $RESOURCE_GROUP -o json --query "[?name=='$CLUSTER_NAME'] | length(@)") = 1 ]]
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
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing
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
  az aks delete --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --no-wait --output table
  echo "Deleting an AKS cluster takes a while."
  echo "Run `az aks list -g $RESOURCE_GROUP` to get the cluster state."
}

installDIH () {
  
  if [[ $CLUSTER_NAME == "B" ]] || [[ $CLUSTER_NAME == "b" ]]
  then 
    return 0 
  fi

  read -p "Would you like to install the DIH umbrella with IIDR [y/n] " INSTALL_IIDR
  if [[ $INSTALL_IIDR =~ [yY](es)* ]];then
    IIDR=true
    #  Add required secrets
  kubectl create secret docker-registry myregistrysecret --docker-server=https://index.docker.io/v1/ --docker-username=dihcustomers --docker-password=dckr_pat_NYcQySRyhRFZ6eUQAwLsYm314QA --docker-email=dih-customers@gigaspaces.com
  kubectl create secret generic datastore-credentials --from-literal=username='system' --from-literal=password='admin11'
  else
    IIDR=false
  fi


    # helm repo add DIH
  helm repo add dih $DIH_HELM_REPO
  helm repo update dih

  # Install ingress-controller
  installIngressController
  
  # Install DIH
    ingressIP=$(kubectl get services  ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
    CMD="helm upgarde --install install dih dih/dih --version $DIH_HELM_CHART --set global.iidrKafkaHost=$ingressIP,tags.iidr=$IIDR -f $DIH_HELM_CONF_FILE"
    echo ------------------------------------
    #echo $CMD
    echo ------------------------------------
    #read -p "Press any key to continue ..."
    echo "Deploying DIH umbrella ..."
    #eval $CMD
    printIngressTCP
}

uninstallDIH () {
  
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
    kubectl delete secret datastore-credentials myregistrysecret
  fi 
  dihMenu
  
}

installOracleDB () {
    
    echo "Installing Oracle DB on k8s cluster ..."
    kubectl create secret docker-registry myregistrysecret --docker-server=https://index.docker.io/v1/ --docker-username=dihcustomers --docker-password=dckr_pat_NYcQySRyhRFZ6eUQAwLsYm314QA --docker-email=dih-customers@gigaspaces.com
    kubectl create secret generic datastore-credentials --from-literal=username='system' --from-literal=password='admin11'
    helm install oracle dih/di-oracle --version 2.0.2
}

installIngressController () {
  # helm repo add DIH and ingress-controller
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update ingress-nginx

  # Install ingress-controller
  helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -f DIH/helm/ingress-controller-tcp.yaml
  
  until [ -n "$(kubectl get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" ]; do
    echo "Waiting for the ingress controller end-point ..."
    sleep 3
  done
  
}

printIngressTCP () {
  installedIngress=$(kubectl get services |grep ingress-nginx-controller |wc -l)
  if [[ $installedIngress -eq 0 ]];then
    echo "Ingress controller is not installed."
    dihMenu
  fi

  ingressIP=$(kubectl get services  ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
  
  echo "Ingress exposed TCP ports:"
  echo ----------------------------------------------------------------------
  cat DIH/helm/ingress-controller-tcp.yaml |grep -v "#" |grep default |tr -d '"' |tr -d ' '|sed 's/:default\// --> /' |cut -d':' -f1 |sed -e "s/^/$ingressIP:/"
  echo ----------------------------------------------------------------------
  echo
  read -p "Enter any key to back to the menu >> " key
}
##### Main #####
clear
loginAzureAccount
mainMenu
