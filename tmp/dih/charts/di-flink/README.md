# This chart contains flink components 
 flink (non-ha definitions from https://nightlies.apache.org/flink/flink-docs-master/docs/deployment/resource-providers/standalone/kubernetes/#common-cluster-resource-definitions)

For first install of chart run following
(Please set correct docker hub password)
```shell
helm install flink-release flink
```

To upgrade chart run
```shell
helm install di-release di
```


Troubleshooting commands:
```shell
kubectl get pods
kubectl get services
kubectl describe pod taskmanager-85b6cb8488-w6pgr
```