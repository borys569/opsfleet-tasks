# Instructions

- Since we do not create the VPC with terraform, we need to make sure that the VPC and subnets are setup correctly (as described here: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)
    - make sure the VPC has private subnets;
    - make sure private subnets have a route to the nat gateways;
    - tag subnets for the ingress controller to work correctly. Those subnets must be specified in terraform variables.

        Private subnets
        Key	Value
        kubernetes.io/role/internal-elb	1

        Public subnets
        Key	Value
        kubernetes.io/role/elb	1

- deploy the EKS cluster with terraform
    - make sure that terraform is installed on your machine.
    - make sure that you have AWS cli installed and configured with an account with enough permission to setup the environment.
    - navigate to opsfleet-terraform/envs/dev . This folder is the root folder from where you will run the terraform code to deploy the environment.
    - Review variables.tf file and edit the input parameters as needed. Make sure ypu specify correct:
        - region
        - aws account id
        - vpc_id
        - private subnets where the nodes will reside
        - eks_instance_types etc.
        - the cluster is defined with a default node setup. Please review the config of "eks_managed_node_groups" in eks-cluster.tf file and adjust if needed.
    - execute `terraform apply` command. It will show you the plan of what objects are about to be created. Review the plan. If ypu are ready to proceed confirm the execution.
    - Creating the environment may take around 30 minutes.
    - Once it is created you can log in to your AWS account in the web Ui and check the status of EKS cluster.


## Access to the cluster

- Once the cluster is created, the AWS account who executed the terraform command gets admin access to the cluster. If you need to define other users, please add their ARNs in the eks-cluster.tf file. See eks-cluster.tf for the details.


## Connecting to the cluster with kubectl cli

- Once the cluster is created, the user needs to generate the kubeconfig file. This instructions assume you have aws cli configured and can access AWS account.

- Verify that you can connect with AWS cli. AWS will respond with your user details.

  `aws sts get-caller-identity`

- generate kubectl config ( ~/.kube/config ). The file holds your keys for the cluster

  `aws eks update-kubeconfig --name <clustername>`

- test cluster connection (make sure you have configured the default namespace in the previous step)

  `kubectl get po -A`

- you should see the list of the pods.


## Deploying test app

The files for this section are located in the "yamls" folder

- Validating role association (This step may be skipped. It is only needed for debugging). create a test deployment to validate if you can access the S3 bucket. . It is only necessary for troubleshooting. This deployment will create a pod with aws cli. You can use it to validate if the role works correctly:  
    `kubectl apply -f _deployment-validate-role.yaml`

    - find pod name:  
        `kubectl get po`
    
    - execute into the pod:  
        `kubectl exec -it PODE_NAME -- /bin/bash`
    
    - Inside the pod shell, execute the commands to see under what role you are accessing AWS resources and try listing the S3 buckets  
        ```
        aws sts get-caller-identity
        aws s3 ls
        ```

- To create actual deployment with your app, you may use _deployment-eample.yaml file. Replace the image name with your actual application image. Please note that this deployment does not expose any app ports as services and does not configure ingress. It only runs an app so you can test it.  
    `kubectl apply -f _deployment-example.yaml`