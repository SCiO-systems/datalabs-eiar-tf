This project provides an automated way to set up an Amazon Elastic Kubernetes Service (EKS) cluster using Terraform. It simplifies the process of provisioning and configuring the necessary resources required to run a scalable and highly available Kubernetes cluster on AWS.

The infrastructure is defined as code using Terraform, allowing for version-controlled and repeatable deployments. By following the steps outlined in this project, you will have a fully functional EKS cluster up and running in no time.

### Prerequisites
Before you begin, ensure that you have the following prerequisites in place:

- An AWS account with sufficient privileges to create and manage EKS resources

- AWS CLI installed and configured on your local machine

- Terraform installed locally (version 0.12 or above)

- Basic knowledge of Kubernetes and AWS services


### Project Structure

#### Root Directory
The root directory contains the main Terraform configuration files for setting up the overarching infrastructure. It includes files for defining providers, shared variables, and outputs.

| File           | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `main.tf`      | The primary entry point for Terraform configuration, orchestrating modules. |
| `providers.tf` | Defines provider configurations (e.g., AWS credentials and region settings). |
| `variables.tf` | Declares input variables shared across the project.                         |
| `outputs.tf`   | Specifies output values for the infrastructure, including module outputs.   |
| `README.md`    | Provides a high-level overview of the project.                              |

---

#### `efs/` Module
The `efs` module is responsible for provisioning **Elastic File System (EFS)** resources. This can include file systems, mount targets, and access points.

| File           | Description                                                                  |
|----------------|------------------------------------------------------------------------------|
| `main.tf`      | Contains the EFS-specific Terraform configurations.                         |
| `variables.tf` | Declares input variables required for the EFS module (e.g., file system size). |
| `outputs.tf`   | Specifies output values related to EFS resources (e.g., file system IDs).   |

---

#### `eks/` Module
The `eks` module provisions an **Elastic Kubernetes Service (EKS)** cluster. This includes the cluster itself, worker nodes, and any associated IAM roles.

| File           | Description                                                                  |
|----------------|------------------------------------------------------------------------------|
| `main.tf`      | Contains the EKS-specific Terraform configurations.                         |
| `variables.tf` | Declares input variables for the EKS module (e.g., cluster name, node types). |
| `outputs.tf`   | Specifies output values related to the EKS module (e.g., cluster endpoint). |

---

#### `vpc/` Module
The `vpc` module handles the provisioning of the **Virtual Private Cloud (VPC)** infrastructure. It includes subnets, route tables, internet gateways, and NAT gateways.

| File           | Description                                                                  |
|----------------|------------------------------------------------------------------------------|
| `main.tf`      | Contains the VPC-specific Terraform configurations.                         |
| `variables.tf` | Declares input variables for the VPC module (e.g., CIDR blocks, subnet sizes). |
| `outputs.tf`   | Specifies output values for VPC resources (e.g., VPC ID, subnet IDs).       |


### Installation
Follow these steps to set up the EKS cluster using Terraform:

1. Initialize Terraform:
   ```shell
   terraform init
   ```

2. Create a Terraform execution plan*:
   ```shell
   terraform plan
   ```

3. Review the execution plan and ensure it aligns with your expectations.

4. Apply the Terraform configuration to create the EKS cluster:
   ```shell
   terraform apply
   ```

5. Wait for the provisioning process to complete. This may take several minutes.

6. Once the cluster is provisioned, retrieve the Kubernetes configuration:
   ```shell
   aws eks update-kubeconfig --name <cluster-name> --region <aws-region> --kubeconfig ~/.kube/config
   ```

7. Verify the cluster is functioning correctly:
   ```shell
   kubectl cluster-info
   ```


*The configuration of the EKS cluster can be customized to suit your specific requirements. The main configuration file is located in the project directory and named `terraform.tfvars`. Open this file to modify the following parameters:

- `name`: The name of the EKS cluster and its needed AWS resources

- `instance_types`: The EC2 instances type for the worker nodes

- `scaling_config_desired_size`: The desired number of the worker nodes

- `scaling_config_min_size`: The minimum number for the worker nodes based on the autoscaling

- `scaling_config_max_size`: The maximum number for the worker nodes based on the autoscaling

Then execute the plan command using the file: `terraform plan -var-file=terraform.tfvars`

Feel free to adjust these parameters and re-run the `terraform apply` command to update your cluster.

### Post-Installation

There could be additional configurations to be made in order to faciliate some needs upon cluster's creation.

#### Provision access to IAM users

By default, only the AWS profile (keys) that will be used will have access to the cluster but other users may want to be able to have access to it.

To do so, you must ammend the `aws-auth` configMap to include them.

1. Fetch the existing configMap:
   ```shell
   kubectl get cm aws-auth -n kube-system -o yaml > aws-auth.yaml
   ```

2. Edit the file by including a `mapUsers` section:
   ```shell
   nano aws-auth.yaml
   ```

      ```shell
      apiVersion: v1
      data:
         mapRoles: |
            - groups:
               - system:bootstrappers
               - system:nodes
               rolearn: arn:aws:iam::555555555555:role/anaoum-eks-worker-nodes-role
               username: system:node:{{EC2PrivateDNSName}}
         mapUsers: |
            - "groups":
               - "system:masters"
               "userarn": "arn:aws:iam::555555555555:user/user1"
               "username": "user1"
            - "groups":
               - "system:masters"
               "userarn": "arn:aws:iam::555555555555:user/user2"
               "username": "user2"
      kind: ConfigMap
      metadata:
         creationTimestamp: "2023-08-04T09:40:00Z"
         name: aws-auth
         namespace: kube-system
         resourceVersion: "865"
         uid: 6dbed3da-1e44-4425-8ca4-96c4a6045b48
      ```

3. Apply the updated manifest:
   ```shell
   kubectl apply -f aws-auth.yaml
   ```
