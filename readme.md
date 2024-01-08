This file provides the instructions on how to use this repo.

# Task #

You've joined a new and growing startup.

The company wants to build its initial Kubernetes infrastructure on AWS.

They have asked you if you can help create the following:

Terraform code that deploys an EKS cluster (whatever latest version is currently available) into an existing VPC
The terraform code should also prepare anything needed for a pod to be able to assume an IAM role
Include a short readme that explains how to use the Terraform repo and that also demonstrates how an end-user (a developer from the company) can run a pod on this new EKS cluster and also have an IAM role assigned that allows that pod to access an S3 bucket.

# Answer #

## Instructions

- Since we are not creating the VPC with terraform, we need to make sure that the VPC and subnets are setup correctly (as described in AWS docs: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)
   - make sure the VPC has private subnets. This is not mandatory but highly recommended form the security stand point to put EKS worker nodes in a private subnet;
   - make sure private subnets have a route to the NAT gateways;
   - tag subnets for the ingress controller to work correctly. Those subnets must be specified in terraform variables.

       Private subnets
       Key Value
       kubernetes.io/role/internal-elb 1

       Public subnets
       Key Value
       kubernetes.io/role/elb  1

- Deploy the EKS cluster with terraform:
   - make sure that terraform binary is installed on your machine.
   - make sure that you have AWS cli installed and configured with an account having enough permission to set up the environment.
   - you may use `brew` utility for mac os to install all of the bowe tools.
   - navigate to `./terraform/envs/dev` folder . It is the root folder from where you will run the terraform code to deploy the environment.
   - Review `variables.tf` file and edit the input parameters as needed. Make sure ypu specify:
       - AWS region
       - aws account id
       - vpc id
       - private subnets ids where the nodes will reside
       - eks_instance_types etc.
       - the cluster is defined with a default node setup. Please review the config of "eks_managed_node_groups" in eks-cluster.tf file and adjust if needed.
   - run `terraform init` to install all the nessesary providers and publick modules.
   - run `terraform apply` command. It will show you the plan of what objects are about to be created. Review the plan. If you are happy with the plan, confirm the execution.
   - Creating the environment may take around 30 minutes.
   - Once it is created you can log in to your AWS account in the web UI and check the status of EKS cluster.


## Access to the cluster

- Once the cluster is created, the AWS account which executed the terraform command gets admin access to the cluster. If you need to define other users, please add their ARNs in the `eks-cluster.tf` file under `aws_auth_users` section. See eks-cluster.tf for the details. There are comments in the file explainig how to add additional accounts.


## Connecting to the cluster with kubectl cli

- Once the cluster is created, the user needs to generate the kubeconfig file. These instructions assume you have aws cli configured and can access AWS account.
- Verify that you can connect with AWS cli. AWS will respond with your user details.
 `aws sts get-caller-identity`

- generate kubectl config ( ~/.kube/config ). The file holds your keys for the cluster. If you changed the name of the cluster in terraform, make sure you provide the same cluster name here:
 `aws eks update-kubeconfig --name eks-opsfleet`

- install kubectl (use `brew` or another method of your choice)
- test cluster connection
 `kubectl get po -A`

- you should see the list of the pods.


## Deploying test app

The files for this section are located in the "yamls" folder.

- Validating role association. This step is providied for testing porpuses and may be skipped. Create a test deployment to validate if you can access the S3 bucket. It is only necessary for troubleshooting. This deployment will create a pod with aws cli. You can use it to validate if the role works correctly: 
   `kubectl apply -f _deployment-validate-role.yaml`

   - find pod name: 
       `kubectl get po`
  
   - start the schell inside the pod: 
       `kubectl exec -it PODE_NAME -- /bin/bash`
  
   - Inside the pod shell, execute the commands to see under what role you are accessing AWS resources and try listing the S3 buckets 
       ```
       aws sts get-caller-identity
       aws s3 ls
       ```

- To create actual deployment with your app, you may use` _deployment-eample.yaml` file. Replace the image name with your application image name. Please note that this deployment only exposes the app port as a kubernetes service. The app is accessible to other deployments in the cluster but the app ports are not exposed externally.
Normally you would want to expose the app externally. For this an ingress resource needs to be configured. the cluster is already setup with AWS ingress controller (aws-load-balancer-controller) which managers ingress resources.
   `kubectl apply -f _deployment-example.yaml`