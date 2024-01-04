You've joined a new and growing startup.

The company wants to build its initial Kubernetes infrastructure on AWS.

They have asked you if you can help create the following:

- Terraform code that deploys an EKS cluster (whatever latest version is currently available) into an existing VPC

- The terraform code should also prepare anything needed for a pod to be able to assume an IAM role

- Include a short readme that explains how to use the Terraform repo and that also demonstrates how an end-user (a developer from the company) can run a pod on this new EKS cluster and also have an IAM role assigned that allows that pod to access an S3 bucket.