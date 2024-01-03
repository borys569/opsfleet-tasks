
- Since we do not create the VPC with terraform, we need to make sure that the VPC and subnets are setup correctly (as described here: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)
    - make sure the VPC has private subnets;
    - make sure private subnets have a route to the nat gateways;
    - tag subnets for EKS to work correctly
    
- test deploy

- setup ingress