This file provides the instructions on how to use this repostory.

# Task #

One of our clients is running Kubernetes on AWS (EKS + Terraform). At the moment, they store secrets like database passwords in a configuration file of the application, which is stored along with the code in Github. The resulting application pod is getting an ENV variable with the name of the environment, like staging or production, and the configuration file loads the relevant secrets for that environment.

We would like to help them improve the way they work with this kind of sensitive data.

Please also note that they have a small team and their capacity for self-hosted solutions is limited.

Provide one or two options for how would you propose them to change how they save and manage their secrets.

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

- Once the cluster is created, the AWS account which executed the terraform command gets admin access to the cluster. If you need to define other users, please add their ARNs in the `eks-cluster.tf` file. See eks-cluster.tf for the details. there are comments in the file explainig how to add additional accounts.


## Connecting to the cluster with kubectl cli

- Once the cluster is created, the user needs to generate the kubeconfig file. These instructions assume you have aws cli configured and can access AWS account.
- Verify that you can connect with AWS cli. AWS will respond with your user details.
 `aws sts get-caller-identity`

- generate kubectl config ( ~/.kube/config ). The file holds your keys for the cluster
 `aws eks update-kubeconfig --name <clustername>`

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

- To create actual deployment with your app, you may use _deployment-eample.yaml file. Replace the image name with your application image name. Please note that this deployment does not expose any app ports as services and does not configure ingress. It only runs an app so you can test it. 
   `kubectl apply -f _deployment-example.yaml`