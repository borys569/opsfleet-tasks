# DB access restrictions

As part of the Kubernetes migration project, one of our clients will migrate all of it’s applications to Kubernetes, however, the database services such as MongoDB (self-managed on EC2 instances) or PostgreSQL (RDS) will continue to run outside of the Kubernetes worker nodes, however, still in the same VPC.

One of the requirements of the client is to restrict access to the MongoDB and PostgreSQL databases only to the services that need it. This means that we won’t be able to allow all the pods running on our Kubernetes clusters to freely access the MongoDB instance.

How would you tackle that requirement? Which options are available to allow the clients to restrict access to the databases?

#####

Move databases to its own private subnets
restrict by subnet? > no this can not be done at pod level


Role based restrictions (for RDS)
Crate a role to allow access to the RDS
Create a service account and assosiate it with the sbove role as described here: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html


some sort of CNI based network level limiting solution ?