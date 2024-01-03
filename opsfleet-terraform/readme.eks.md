# Getting access to the cluster as admin

- list clusters

 ` aws eks list-clusters`

- Use the same account who created the cluster (terrafrorm usr in our case) to setup kubectl config file

  `aws eks update-kubeconfig --name <clustername>`

- Update aws-auth configmap to include other ARNs 

  `kubectl --namespace=kube-system describe configmap aws-auth`

- The blow configmap gives access to all with in OrganizationAccountAccessRole role

```
 mapRoles:
----
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: arn:aws:iam::121544126352:role/terraform-eks-dev-node
  username: system:node:{{EC2PrivateDNSName}}
- groups:
  - system:masters
  rolearn: arn:aws:iam::121544126352:role/OrganizationAccountAccessRole
  username: OrganizationAccountAccessRole
```

# How to add users to EKS

aws-configmap.tf defines the roles and user list for developers.

# Getting access to the EKS cluster as a user

## Viewing cluster info in AWS console

- Open AWS console.
- Go to EKS (Elastic Kubernetes Services).
- Select the cluster.
- V3 Dev cluster name is 'eks-opsfleet'
- Go to Resources > Pods.
- Select a desired namespace (`develop` for example).
- Select a pod (`backen-service-<hash>`) to see pod properties and status.

## Viewing the logs in AWS Console

- Open AWS console.
- Go to  CloudWatch > Log Groups.
- Select “/aws/containerinsights/terraform-eks-dev/application” log group.
- Inside the log group, you must search for a “stream” related to your namespace and appname. The stream with the latest update date will correspond to the recently deployed pod.

## Connecting to the cluster with kubectl cli

This allows to see app logs and all EKS objecst in read only mode.

- Install AWS cli and kubectl (if you don't have brew, google it)

  `brew install awscli kubernetes-cli`

- add your Access Keys to `~/.aws/credentials` file. Your AWS admin will provide the key for you.

```
[default]
aws_access_key_id = XXXX
aws_secret_access_key = XXXXXXXX
```

- Verify that you can connect with AWS cli. AWS will respond with your user details.

  `aws sts get-caller-identity`

- generate kubectl config ( ~/.kube/config ). the file holds your keys for the cluster

  `aws eks update-kubeconfig --name <clustername>`

- set default namespace for the current k8s context

  `kubectl config set-context --current --namespace develop`

- test cluster connection (make sure you have configured the default namespace in the previous step)

  `kubectl get po`

- you should see the list of the pods. Example output:

```
NAME                                                    READY   STATUS             RESTARTS            AGE
backend-service-78dcfc4f88-z4np9                        1/1     Running            0                   24m
backend-service-db-location-postgresql-0                1/1     Running            0                   17h
backend-service-db-postgresql-0                         1/1     Running            0                   26m
loop-mock-bff-v3-7fd78cf95-wgd8k                        0/1     CrashLoopBackOff   30259 (2m58s ago)   108d
loop-node-links-549d8f9f48-58lgn                        1/1     Running            0                   20h
loop-web-fe-v3-7958586c4f-bxz26                         1/1     Running            0                   16h
redis-master-0                                          1/1     Running            0                   19h
redis-replicas-0                                        1/1     Running            0                   19h
redis-replicas-1                                        1/1     Running            0                   19h
redis-replicas-2                                        1/1     Running            0                   19h
renewage-hubspot-5dcdf6899-kqs27                        1/1     Running            0                   183d
renewage-landing-7675d8dfc8-fdmcz                       1/1     Running            0                   183d
sessionmanagement-session-management-6775455f6d-bx56b   1/1     Running            0                   4d2h
```

- get logs from a pod

  `kubectl logs <pod name here>`

- tail logs from a pod

  `kubectl logs -f <pod name here>`

- For other K8S commands please see https://kubernetes.io/docs/reference/kubectl/cheatsheet/.  
Good luck <3

## Certificate management (cert-manager addon)

We used to upload manually generated certs to our EKS. Now we need to replace process with cert-manager. It provides a fully automated methods of managing certificates (https://cert-manager.io/docs/usage/).

TLDR:
- cert-manager addon is required.
- ClusterIssuer resource is required.
- The above is already implemented. We just need to add the annotations to existing ingres definitions (helm charts)
- additional annotations in ingress definition to instruct cert manager to generate a cert for the given ingress configuration. Example:
```
Name:             osm-seed-ingress-web
Labels:           app.kubernetes.io/managed-by=Helm
Namespace:        osm-seed
Address:
Ingress Class:    <none>
Default backend:  <default>
TLS:
  osm-seed-secret-web terminates web.osmseed.dragonfyre.io
Rules:
  Host                       Path  Backends
  ----                       ----  --------
  web.osmseed.dragonfyre.io
                             /   osm-seed-web:80 (10.0.1.218:80)
Annotations:                 acme.cert-manager.io/http01-edit-in-place: true
                             cert-manager.io/cluster-issuer: letsencrypt-prod-issuer
                             kubernetes.io/ingress.class: nginx
                             meta.helm.sh/release-name: osm-seed
                             meta.helm.sh/release-namespace: osm-seed
Events:
  Type    Reason             Age   From          Message
  ----    ------             ----  ----          -------
  Normal  CreateCertificate  26m   cert-manager  Successfully created Certificate "osm-seed-secret-web"
```


## The sources used to create this guide:  
- https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html  
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding
