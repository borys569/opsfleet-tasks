# Task #

One of our clients is running Kubernetes on AWS (EKS + Terraform). At the moment, they store secrets like database passwords in a configuration file of the application, which is stored along with the code in Github. The resulting application pod is getting an ENV variable with the name of the environment, like staging or production, and the configuration file loads the relevant secrets for that environment.

We would like to help them improve the way they work with this kind of sensitive data.

Please also note that they have a small team and their capacity for self-hosted solutions is limited.

Provide one or two options for how would you propose them to change how they save and manage their secrets.

# Answer #

## AWS secret manager ##

## 1

I would recommend using AWS secret manager. It is a native AWS solution which is really easy to integrate with.
The secret manager allows to store secrets and control over the access to the secrets via IAM.
The approach can look like this:
- Store secrets in the secret manager;
- For each application create a role to allow reading only the required secrets;
- The role is assigned to a Service Account in EKS (IAM roles for service accounts), allowing a pod to read certain secret.

## 2

https://community.aws/tutorials/navigating-amazon-eks/eks-integrate-secrets-manager

## Kubernetes secrets ##

Another simple solution is to use native kubernetes secrets
With this approach you can:
- avoid keeping secrets in the Code, which is a big security risc;
- granularly control the application(pod) access to the secrets;
This isn't the most secure approach but it covers the basic security risks while being easy to implement and manage. And in may cases, simple implementation means robust system. And less complexity means smaller attack surface. 
There is an intresting article about the security of kubernetes secrets: https://www.macchaffee.com/blog/2022/k8s-secrets/

