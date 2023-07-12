# This chart contains di subscription manager

For first install of chart run following
(Please set correct docker hub password)
```shell
kubectl create secret docker-registry myregistrysecret --docker-server=https://index.docker.io/v1/ --docker-username=dihcustomers --docker-password=dckr_pat_NYcQySRyhRFZ6eUQAwLsYm314QA --docker-email=dih-customers@gigaspaces.com
helm install di-subscription-manager-release di-subscription-manager
```

To upgrade chart run
```shell
helm upgrade di-subscription-manager-release di-subscription-manager
```

Troubleshooting commands:
```shell
kubectl get pods
kubectl get services
# get detailed information of pod including restarts reasons etc.
kubectl describe pod di-subscription-manager
# connect to shell of some pod
kubectl exec --stdin --tty svc/di-subscription-manager -- /bin/bash
```
