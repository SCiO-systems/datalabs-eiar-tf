This project is a modular Terraform infrastructure setup designed to provision and manage an EKS (Elastic Kubernetes Service) cluster with associated VPC (Virtual Private Cloud) and EFS (Elastic File System) resources. The structure follows a modular approach, with reusable components organized into separate directories.

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


### Variables Explanation

Below is a detailed explanation of the variables required for this project:

| Variable Name      | Type                        | Default Value                  | Description                                                                                   |
|--------------------|-----------------------------|--------------------------------|-----------------------------------------------------------------------------------------------|
| `region`           | `string`                   | `"eu-central-1"`               | The AWS region where the infrastructure will be provisioned.                                 |
| `name`             | `string`                   | `"anaoum"`                     | A project-specific name used for tagging and identification of resources.                    |
| `customer`         | `string`                   | `"fys"`                        | A customer-specific identifier used for tagging and resource organization.                   |
| `public_cidrs`     | `list(string)`             | `["10.0.100.0/24", "10.0.101.0/24"]` | The CIDR blocks for the public subnets within the VPC.                                       |
| `private_cidrs`    | `list(string)`             | `["10.0.102.0/24", "10.0.103.0/24"]` | The CIDR blocks for the private subnets within the VPC.                                      |
| `vpc_id`           | `string`                   | `"vpc-xxx"`                    | The ID of the VPC where the resources will be created.                                       |
| `private_rtb_id`   | `string`                   | `"rtb-yyy"`                    | The ID of the private route table associated with the private subnets.                      |
| `public_rtb_id`    | `string`                   | `"rtb-zzz"`                    | The ID of the public route table associated with the public subnets.                        |
| `node_groups`      | `list(object)`             | (See Below)                    | Configuration for EKS node groups, including instance types, disk size, and scaling limits. |

#### Default Value for `node_groups`
The `node_groups` variable is a list of objects that define the configuration for EKS worker node groups. Each object includes the following fields:
- `instance_types`: A list of instance types (e.g., `["t3.medium"]`) to be used in the node group.
- `disk_size`: The size of the disk (in GB) for each instance.
- `desired_size`: The desired number of instances in the node group.
- `max_size`: The maximum number of instances the node group can scale up to.
- `min_size`: The minimum number of instances in the node group.

#### Default Node Group Configuration:
```hcl
[
  {
    instance_types = ["t3.medium"]
    disk_size      = 20
    desired_size   = 2
    max_size       = 5
    min_size       = 1
  },
  {
    instance_types = ["t3.large"]
    disk_size      = 30
    desired_size   = 1
    max_size       = 3
    min_size       = 1
  }
]
```

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
