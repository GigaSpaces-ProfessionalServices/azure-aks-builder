# BBW - DIH on azure

## Goal:
* Provision a k8s cluster in azure (AKS) via the Jumper
* Installing the DIH generic umbrella
* Installing the DIH BBW-Use-Case-1 umbrella.
-----------
# Prerequisites
---------------
## Export the ARM variables
```
export ARM_CLIENT_ID="xxxxxxxxxxxx" <will be provided separately>
export ARM_CLIENT_SECRET="xxxxxxxxxxxx" <will be provided separately>
export ARM_SUBSCRIPTION_ID="xxxxxxxxxxxx" <will be provided separately>
export ARM_TENANT_ID="xxxxxxxxxxxx" <will be provided separately>
```

# Launce a Jumper VM in azure
1. Download/clone this git project to any machine which can access your azure account via azure cli.
2. ```
   cd BBW-DIH-k8s/Jumper/createJumper
    
   ./createAzureJumper.sh 

   Jumper Name (prefix: bbw-jumper): bbw-jumper-test
   Public ssh key (full path): /path/to/sshkey.pub
   Tags | Owner: bbw
   Tags | Project: bbw
   Starting Jumper VM provisioning...
   ```
   Wait for the VM to created.
   ```
   ResourceGroup    PowerState    PublicIpAddress    Fqdns    PrivateIpAddress    MacAddress         Location    Zones
   ---------------  ------------  -----------------  -------  ------------------  -----------------  ----------  -------
   csm-bbw          VM running    x.x.x.x                     10.0.0.6            ##-##-##-##-##-##  eastus
   ```

   Note: Once the VM has been launched, a userdata script will start running. It might be takes a while until all the Jumper tools will be installed.

3. Login to the Jumper VM by: (user: centos)
   ```
   ssh -i /path/to/sshkey.pub centos@jumper-ip

4. Update the setEnv.sh

   The scripts in this project require credentials for azure and datadog.
   Please update the BBW-DIH-k8s/scripts/setEnv.sh with your environment details:

   ```
   ### Azure 
   export resource_group_name=""
   export ARM_CLIENT_ID=""
   export ARM_CLIENT_SECRET=""
   export ARM_SUBSCRIPTION_ID=""
   export ARM_TENANT_ID=""
   ```
   ```
   ### datadog integration bbw-demo
   export datadog_api_key=""
   export datadog_app_key=""
   ```


# Create an AKS cluster (k8s on azure)
  From the Jumper you have crated at the previous step:
  ```
  cd BBW-DIH-k8s

  Make sure you have updated the scripts/setEnv.sh script.
  Enter to the menu:
  ```
  ./menu.sh

  
```
Welcome to DIH Builder on Azure!
--------------------------------

1. AKS Management
2. DIH Management
E. Exit
```
     
Choose AKS Management (1) and follow the instructions.

To check the Availability Zones after the AKS cluster has been created, run:
```
./display_az.sh


NAME                                  REGION   ZONE
aks-bbwnodepool-33196474-vmss000000   eastus   eastus-2
aks-bbwnodepool-33196474-vmss000001   eastus   eastus-3
aks-bbwnodepool-33196474-vmss000002   eastus   eastus-1
```

---------------------------------------

# Deploy dih the umbrella
Back to the Main menu or run ./menu.sh
```
  Welcome to DIH Builder on Azure!
  --------------------------------

   1. AKS Management
   2. DIH Management
   E. Exit
```
Choose DIH Management (2)
```
DIH Management
--------------
Fetching clusters ...
Name      Location    ResourceGroup    KubernetesVersion    CurrentKubernetesVersion    ProvisioningState    Fqdn
--------  ----------  ---------------  -------------------  --------------------------  -------------------  --------------------------------------
bbw-demo  eastus      csm-bbw          1.24.9               1.24.9                      Succeeded            bbw-demo-c97fc1db.hcp.eastus.azmk8s.io

Please provide a Cluster Name: bbw-demo
```

```
DIH Management
--------------
Cluster: [ bbw-demo ]

1. Install the generic DIH umbrella
2. Install the bbw use-case-1 umbrella
3. Install datadog agent
-----------------------------------------------------------------
4. Uninstall the generic DIH umbrella
5. Uninstall the bbw use-case-1 umbrella
6. Uninstall datadog agent
7. Uninstall ALL
-----------------------------------------------------------------
B. Back to Main menu.
E. Exit

>> 1
```
Choose 1 to install the generic dih umbrella (1).

### Repeat the previous steps for bbw-dih-use-case-1 umbrella (2) and for datadog (3)
------------

# Appendix 1: ingress-tcp ports

  |ingress port|namespace|serviceName|servicePort|
  |----|-------|-------------------|-----|
  |8090|default|xap-manager-service|8090|
  |3030|default|grafana|3000|
  |3000|default|bbw-dih-spacedeck|3000|
  |8080|default|kafka-ui|8080|
  |8081|default|bbw-kafka-producer-svc|8081|
  |6085|default|bbw-dih-pc-pluggable-connector|6085|
  |9000|kubernetes-dashboard|kubernetes-dashboard|443|
  |9092|default|influxdb-kapacitor-kapacitor|9092|
  |8086|default|influxdb|8086|


# azure-aks-builder
