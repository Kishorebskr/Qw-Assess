# Tech challenge - kubernetes autoamted infra provision & HPA ###

This repository demonstrates the end-to-end automation of infrastructure provisioning and application deployment on Amazon EKS using Terraform and Kubernetes. 
It includes Terraform configurations to create and manage the underlying AWS infrastructure, Kubernetes manifests to deploy and scale the application with Horizontal Pod Autoscaling (HPA), and a GitHub Actions CI/CD pipeline that automates infrastructure provisioning, container image management, and Kubernetes rollouts.

---

## Repository Contents  ##########

* **Terraform**

  * main.tf: I defined the EKS cluster, VPC, and related resources.
  * variables.tf: Inside the variable definitions are articualtedto parameterize the Terraform configuration.
  * bootstrap.tf: Bootstrap is configured for the remote backend resources (S3 + DynamoDB) for Terraform state management.
  
* **Kubernetes Manifests**

  * deployment.yaml: This particulat yaml describes the Deployment specification to manage the desired state of the application pods, ensuring the correct number of replicas are always running. It also specifies resource requests/limits for efficient scheduling.
  * service.yaml: The service yaml configures the Service to expose the application internally within the cluster by mapping the container port to a stable cluster IP and port. It allows other Kubernetes components or external clients to reliably access the application.
  * ingress.yaml: Here i have included the Ingress resource to route external HTTP traffic into the cluster, mapping hostnames and paths to the Service. It enables controlled external access to the application.
  * hpa.yaml: The Horizontal Pod Autoscaler (HPA) has been configured to automatically adjust the number of replicas in the Deployment based on CPU utilization thresholds. It ensures the application scales up under load and scales down when idle.
  * namespace.yaml: This manifest creates a Namespace to logically isolate the application resources, improving manageability and separation of environments within the cluster.
  * pdb.yaml: This manifest configures a Pod Disruption Budget (PDB) to maintain high availability during voluntary disruptions (like node drains or upgrades) by ensuring at least one pod remains available.


* **CI/CD**
  * deploy.yml: This is the githuba ctions workflow file that automates Terraform infrastructure deployment and Kubernetes application rollout through GitHubactions.

---

## Highlights

 -->I've configured the pipeline to use an "S3 bucket" for remote state storage and a "DynamoDB table" for state locking.
 -->Implemented PDB(Pod desruption Budget) to ensure the high availability. 
 
 
## Security

 --> Ahered with SOC-1 security practices like storing environment secret credentials like AWS secrets etc., in Github Actions.
 --> when it comes to production scenario the Policy gates can be enforced for branch, environment, and image restrictions before deploys.

## Below Enhacement can be done (not included in this project)

 -->I can setup the readiness/liveliness probe to ensure the pod health.
 --> And also i would implement "OIDC authentication" for GitHub Actions instead of long-lived AWS credentials for the fine grained authentication.


## CI/CD Pipeline

* The workflow(deploy.yml) builds a Docker image, pushes it to "ECR", updates the EKS kubeconfig, and applies manifests.
* Image tagging uses commit SHA for traceability.
* Rollout verification is performed with `kubectl rollout status`.
* Recommendations:

---
Repository structure


repo/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── bootstrap.tf
│   └── backend.hcl
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   ├── namespace.yaml
│   └── pdb.yaml
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
└── README.md





## References

* [Terraform S3 Backend Documentation](https://developer.hashicorp.com/terraform/language/backend/s3)
* [AWS: Terraform Backend Best Practices](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/backend.html)
* [AWS Blog: Managing Terraform State Files in CI/CD](https://aws.amazon.com/blogs/devops/best-practices-for-managing-terraform-state-files-in-aws-ci-cd-pipeline/)
* \[AWS EKS Best Practices: Probes & Health Checks]\([https://docs.aws.amazon.com/prescriptive-guidance/latest/ha-resiliency-amazon-eks-app](https://docs.aws.amazon.com/prescriptive-guidance/latest/ha-resiliency-amazon-eks-app)
* Some parts of this work were assisted using GitHub Copilot, primarily for boilerplate generation and formatting like terrafrom resource block.



## HLD Architecture





