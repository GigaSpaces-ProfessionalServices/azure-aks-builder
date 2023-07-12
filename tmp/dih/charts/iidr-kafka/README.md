# This chart contains iidr kafka without kafka

For first install of chart run following
(Please set correct docker hub password)
```shell
kubectl create secret docker-registry myregistrysecret --docker-server=https://index.docker.io/v1/ --docker-username=dihcustomers --docker-password=dckr_pat_NYcQySRyhRFZ6eUQAwLsYm314QA --docker-email=dih-customers@gigaspaces.com
kubectl create secret generic datastore-credentials --from-literal=username='system' --from-literal=password='admin11'
helm install iidr-kafka-release iidr-kafka
```

To upgrade chart run
```shell
helm upgrade iidr-kafka-release iidr-kafka
```

Troubleshooting commands:
```shell
kubectl get pods
kubectl get services
# get detailed information of pod including restarts reasons etc.
kubectl describe pod iidr-kafka
# connect to shell of some pod
kubectl exec --stdin --tty svc/iidr-kafka -- /bin/bash
```
