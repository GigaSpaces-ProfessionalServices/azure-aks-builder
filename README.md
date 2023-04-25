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
Reasource Group: gng-lab

1. AKS Management
2. DIH Management
E. Exit

>>

```

