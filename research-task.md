# Task #

One of our clients is running Kubernetes on AWS (EKS + Terraform). At the moment, they store secrets like database passwords in a configuration file of the application, which is stored along with the code in Github. The resulting application pod is getting an ENV variable with the name of the environment, like staging or production, and the configuration file loads the relevant secrets for that environment.

We would like to help them improve the way they work with this kind of sensitive data.

Please also note that they have a small team and their capacity for self-hosted solutions is limited.

Provide one or two options for how would you propose them to change how they save and manage their secrets.

# Answer #

## AWS secret manager ##

Since the customer is using AWS services, the most straightforward and easy to manage solution would be AWS secret manager.
The secret manager allows to store secrets and control the access to the secrets via IAM roles. I've been using this approach on my recent project and all the devs were really happy with this.
The approach will look like this:
- Store secrets in the secret manager;
- For each application create a role to allow reading only the required secrets;
- The role is assigned to a Service Account in EKS (IAM roles for service accounts), allowing a pod to read certain secrets.
- There are a few way to read the secrets:
    - the app can natively consume AWS secrets (requires small changes on the app code side)
    - secrets can be mounted as files to the pods. This way, no code changes are required.

Detailed information on this approach can be found here: https://community.aws/tutorials/navigating-amazon-eks/eks-integrate-secrets-manager

## Kubernetes secrets

Another simple solution is to use native kubernetes secrets. With this approach you can:
- Avoid keeping secrets in the codebase, which is a big security risk;
- Granularly control the application(pod) access to the secrets;  
This approach covers the basic security risks while being easy to implement and manage. And in many cases, simple implementation means a robust system. Also less complexity means smaller attack surface. 
And since we use a managed EKS service we can be certain that our etcd service is secure and backed up so we do not lose our secrets.


## Hashicorp vault

This is a more complex approach as one has to set up and manage the Hashicorp vault.
- This approach is similar to the approach with AWS secret manager.
- Secrets are stored in the vault;
- Secrets can be mounted to pods as a volume. This requires the [Secrets Store CSI Driver](https://github.com/kubernetes-sigs/secrets-store-csi-driver).
Hashicorp vault also supports other secret retrieval methods: apps can request the secrets from the vault via API or secrets can be injected into pods by [Vault Agent containers](https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-sidecar).