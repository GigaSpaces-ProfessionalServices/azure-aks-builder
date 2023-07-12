# This chart contains all di components except of iidr as explicit templates
* mdm
* di-manager
* di-operator

Chart doesn't apply by default global configuration and uses sqlite as a repository
To enable zookeeper repository:
`repositoryProfile: zookeeper`
To run global config
`doGlobalConfig: true`
This will use configuration values from global section


For first install of chart run following
(Please set correct docker hub password)
```shell
kubectl create secret docker-registry myregistrysecret --docker-server=https://index.docker.io/v1/ --docker-username=dihcustomers --docker-password=dckr_pat_NYcQySRyhRFZ6eUQAwLsYm314QA --docker-email=dih-customers@gigaspaces.com
helm dependency build
helm install di-release .
```

To upgrade chart run
```shell
helm dep up # to upgrade dependencies if needed
helm upgrade di-release .
```

## Troubleshooting commands:
```shell
kubectl get pods
kubectl get services
# get detailed information of pod including restarts reasons etc.
kubectl describe pod taskmanager-85b6cb8488-w6pgr
# connect to shell of some pod
kubectl exec --stdin --tty svc/di-mdm -- /bin/bash
Check mdm logs:
cat /di/logs/global_config.out
```

View mdm logs from di-operator
```shell
kubectl exec --stdin --tty di-operator-795b74d45c-zp5qf -- /bin/bash
[gsods@di-operator ~]$ cat /di/logs/global_config.out
```

## Useful port forwarding commands
```shell
kubectl port-forward svc/di-mdm 6081
kubectl port-forward svc/di-manager 6080
```
DI-manager swagger: http://localhost:6080/swagger-ui

DI-mdm swagger: http://localhost:6081/swagger-ui

