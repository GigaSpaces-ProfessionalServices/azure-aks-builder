# azure AKS builder

Use this project to:

* Create or delete an AKS cluster
* Deploy or undeploy DIH and ingress-controller on a k8s cluster
 

## Edit the setEnv.sh
In this file you should set the following:
- Jumper: VM size, public key, userdata script
- AKS: nodes VM size, nodes count
- Resource Group
- Location
- azure credentials (ARM_ variables, also can be set at ~/.bashrc)
```
#!/bin/bash
RESOURCE_GROUP=gng-lab
TAG_GSPOLICY=noprod
LOCATION=eastus
AKS_NODE_COUNT=3
AKS_VM_SIZE="Standard_B2ms"

JUMPER_IMAGE="OpenLogic:CentOS:7_9:latest"
JUMPER_USERDATA="AKS/userdata-install_jumper_tools.sh"
JUMPER_ADMIN_USER="centos"
JUMPER_PUBLIC_KEY="AKS/gng.pub"
JUMPER_SIZE="Standard_B4ms"

# ARM_CLIENT_ID=
# ARM_CLIENT_SECRET=
# ARM_SUBSCRIPTION_ID=
# ARM_TENANT_ID=
```

## Run the dih-builder tool
```
./dih-builder.sh
```
Upon successful login, you will see this menu:
```
Login to azure ...
Login succeeded.
Welcome to DIH Builder on Azure!
--------------------------------

Subscription: support.gigaspaces.com
Client ID: 49664c5d-130b-4463-b538-506f85f3ba0d
Resource Group: gng-lab

1. AKS Management
2. DIH Management
E. Exit

>>

```
### AKS Management Menu
```
AKS management
--------------

1. Set a current AKS cluster (update kubeconfig)
2. Create a new AKS cluster
3. Delete an AKS Cluster
4. Create an Jumper VM
B. Back to Main menu.
E. Exit

>> 1
AKS management
--------------

1. Set a current AKS cluster (update kubeconfig)
2. Create a new AKS cluster
3. Delete an AKS Cluster
4. Create an Jumper VM
B. Back to Main menu.
E. Exit

>> 2

Cluster Name: gng-test1
Project: gng
Owner: Shmulik
Would you like to create a jumper vm for this AKS? [y/n] y
Creating an AKS cluster [ gng-test1 ]
AzurePortalFqdn                                                CurrentKubernetesVersion    DisableLocalAccounts    DnsPrefix                 EnableRbac    Fqdn                                                    KubernetesVersion    Location    MaxAgentPools    Name       NodeResourceGroup            ProvisioningState    ResourceGroup
-------------------------------------------------------------  --------------------------  ----------------------  ------------------------  ------------  ------------------------------------------------------  -------------------  ----------  ---------------  ---------  ---------------------------  -------------------  ---------------
gng-test1-gng-lab-b5cedc-be1v1154.portal.hcp.eastus.azmk8s.io  1.25.6                      False                   gng-test1-gng-lab-b5cedc  True          gng-test1-gng-lab-b5cedc-be1v1154.hcp.eastus.azmk8s.io  1.25.6               eastus      100              gng-test1  MC_gng-lab_gng-test1_eastus  Succeeded            gng-lab
createJumper
 
```

### DIH Management Menu
```
DIH management
--------------

1. Install DIH umbrella
2. Uninstall DIH umbrella
B. Back to Main menu.
E. Exit

>> 1
Fetching clusters ...
Name       Location    ResourceGroup    KubernetesVersion    CurrentKubernetesVersion    ProvisioningState    Fqdn
---------  ----------  ---------------  -------------------  --------------------------  -------------------  ------------------------------------------------------
gng-dev1   eastus      gng-lab          1.25.6               1.25.6                      Succeeded            gng-dev1-gng-lab-b5cedc-5r2el0x4.hcp.eastus.azmk8s.io
gng-test1  eastus      gng-lab          1.25.6               1.25.6                      Succeeded            gng-test1-gng-lab-b5cedc-be1v1154.hcp.eastus.azmk8s.io

Enter the cluster name to set as the current context: (to the pervious menu type B/b)
>> gng-test1
Updating kube config file for [ gng-test1 ] cluster ...
Merged "gng-test1" as current context in /home/centos/.kube/config
Current context: gng-test1
Would you like to install the DIH umbrella with IIDR [y/n] y
Deploying DIH umbrella ...
error: failed to create secret secrets "myregistrysecret" already exists
error: failed to create secret secrets "datastore-credentials" already exists
"dih" already exists with the same configuration, skipping
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "dih" chart repository
Update Complete. ⎈Happy Helming!⎈
"ingress-nginx" already exists with the same configuration, skipping
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ingress-nginx" chart repository
Update Complete. ⎈Happy Helming!⎈
NAME: ingress-nginx
LAST DEPLOYED: Tue Apr 25 11:18:10 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace default get services -o wide -w ingress-nginx-controller'

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
NAME: dih
LAST DEPLOYED: Tue Apr 25 11:18:34 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
*It may take a few minutes for the environment to be available*
```
After a while, you will be able to see the pods:
```
kubectl get pod
NAME                                       READY   STATUS     RESTARTS        AGE
di-manager-65488546b9-zdltn                1/1     Running    0               4m24s
di-mdm-76b5475d79-6s6d4                    1/1     Running    0               4m24s
di-operator-766698679b-vpc8b               1/1     Running    0               4m24s
di-subscription-manager-c7d878b7d-vmblt    1/1     Running    0               4m24s
flink-jobmanager-5676cf895b-fjbsg          1/1     Running    2 (90s ago)     4m24s
flink-taskmanager-7697dd7c46-6llpm         1/1     Running    3 (75s ago)     4m23s
flink-taskmanager-7697dd7c46-9797q         1/1     Running    2 (97s ago)     4m24s
grafana-dc45d89b-j2882                     2/2     Running    0               4m24s
iidr-as-548bf8c86f-nm69t                   1/1     Running    0               4m24s
iidr-kafka-794d9bf677-dd7j5                1/1     Running    0               4m24s
influxdb-0                                 1/1     Running    0               4m24s
ingress-nginx-controller-7fb846b98-lpf2w   1/1     Running    0               4m51s
kafka-0                                    1/1     Running    0               4m24s
kafka-1                                    1/1     Running    0               4m24s
kafka-2                                    1/1     Running    0               4m24s
redpanda-54c6454c6d-bltc4                  1/1     Running    3 (89s ago)     4m24s
service-creator-7465566ffd-2rqkz           1/1     Running    0               4m24s
service-operator-6566f55b6f-zsvwz          1/1     Running    0               4m24s
spacedeck-74b99767c4-mfnwl                 1/1     Running    1 (2m32s ago)   4m24s
xap-manager-0                              1/1     Running    0               4m24s
xap-manager-1                              0/1     Init:0/1   0               73s
xap-operator-6ffd875c68-c924r              1/1     Running    0               4m24s
zookeeper-0                                1/1     Running    0               4m24s
zookeeper-1                                1/1     Running    0               4m24s
zookeeper-2                                1/1     Running    0               4m24s
```

### DIH Uninstall Menu
```
DIH management
--------------

1. Install DIH umbrella
2. Uninstall DIH umbrella
B. Back to Main menu.
E. Exit

>> 2
Fetching clusters ...
Name      Location    ResourceGroup    KubernetesVersion    CurrentKubernetesVersion    ProvisioningState    Fqdn
--------  ----------  ---------------  -------------------  --------------------------  -------------------  -----------------------------------------------------
gng-dev1  eastus      gng-lab          1.25.6               1.25.6                      Succeeded            gng-dev1-gng-lab-b5cedc-5r2el0x4.hcp.eastus.azmk8s.io

Enter the cluster name to set as the current context: (to the previous menu type B/b)
>> gng-dev1
Updating kube config file for [ gng-dev1 ] cluster ...
Merged "gng-dev1" as current context in /home/centos/.kube/config
Current context: gng-dev1
Are you sure you want to uninstall DIH from gng-dev1? [y/n]: y
Remove ingress-controller from gng-dev1? [y/n]: n
```

## Access service by ingress-ip:ingress-port

| Ingress Port | Service Name | Service Port |
---------------|--------------|--------------|
| 8090 | xap-manager-service|8090|
|  3030 | grafana|3000|
|  3000 | spacedeck|3000|
|  8080 | redpanda|8080|
|  6080 | di-manager|6080|
|  6081 | di-mdm|6081|
|  6082 | di-subscription-manager|6082|
|  8181 | flink-jobmanager|8081|
|  5432 | xap-dgw-service|5432|
|  11701| iidr-kafka|11701|

Note: You can access spacedeck by http://ingress-ip/ without specifying :3000 port

To find your ingress-IP run:
```
kubectl get svc ingress-nginx-controller -o json | jq -r .status.loadBalancer.ingress[].ip
```