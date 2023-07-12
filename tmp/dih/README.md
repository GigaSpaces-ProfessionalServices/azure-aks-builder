# Installing All DIH Umbrella Chart

## Prerequisites

* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [helm](https://docs.helm.sh/using_helm/#quickstart-guide)
* Kubernetes 1.9+ cluster (cloud, on-premise, or local via [minikube](https://kubernetes.io/docs/setup/minikube/))


This chart will do the following:

* Create a full di umbrella including iidr-as and iidr-kafka minus di-oracledb and iidr-oracle

For first install of chart run following
(Please set correct docker hub password)
```shell
kubectl create secret docker-registry myregistrysecret --docker-server=https://index.docker.io/v1/ --docker-username=dihcustomers --docker-password=dckr_pat_NYcQySRyhRFZ6eUQAwLsYm314QA --docker-email=dih-customers@gigaspaces.com
kubectl create secret generic datastore-credentials --from-literal=username='system' --from-literal=password='admin11'
```

## Installing the Chart locally

```console
helm upgrade --install all-dih \
--set spacedeck.auth.enabled=false,manager.securityService.enabled=false,spacedeck.ingress.enabled=true,tags.iidr=true
```

## Installing the Chart from chart repository

```console
helm repo add dih-repo https://s3.amazonaws.com/resources.gigaspaces.com/helm-charts-dih
helm upgrade --install all-dih dih-repo/dih --version 16.3.0 \
--set spacedeck.auth.enabled=false,manager.securityService.enabled=false,spacedeck.ingress.enabled=true,tags.iidr=true
```

## Warning
### Remove all the PVC's upon uninstallation of the cluster

```console
helm uninstall all-dih 
kubectl delete pvc --all
```
## Configuration

You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install all-dih -f values.yaml
```
