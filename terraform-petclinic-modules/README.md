# PetClinic Terraform

This folder keeps shared modules and separate root stacks so each service has its own Terraform state.

```text
terraform-petclinic-modules/
  modules/
    eks/
    ecr/
    rds/
  ecr/
    envs/dev/backend.hcl
    envs/dev/terraform.tfvars
  eks/
    envs/dev/backend.hcl
    envs/dev/terraform.tfvars
  rds/
    envs/dev/backend.hcl
    envs/dev/terraform.tfvars
```

`platform-infra/network` owns VPC, subnets, NAT, and route tables. These stacks only create:

- `ecr`: PetClinic ECR repository
- `eks`: EKS cluster and managed node group, using network remote state
- `rds`: private MySQL RDS, using network remote state and EKS remote state

## First Setup

Copy each example file once:

```bash
cp ecr/envs/dev/backend.hcl.example ecr/envs/dev/backend.hcl
cp ecr/envs/dev/terraform.tfvars.example ecr/envs/dev/terraform.tfvars

cp eks/envs/dev/backend.hcl.example eks/envs/dev/backend.hcl
cp eks/envs/dev/terraform.tfvars.example eks/envs/dev/terraform.tfvars

cp rds/envs/dev/backend.hcl.example rds/envs/dev/backend.hcl
cp rds/envs/dev/terraform.tfvars.example rds/envs/dev/terraform.tfvars
```

Replace `your-tfstate-bucket-name` with the same bucket used by `platform-infra/network`.

## Apply Order

ECR:

```bash
cd terraform-petclinic-modules/ecr
terraform init -backend-config=./envs/dev/backend.hcl
terraform plan -var-file=./envs/dev/terraform.tfvars
terraform apply -var-file=./envs/dev/terraform.tfvars
```

EKS:

```bash
cd ../eks
terraform init -backend-config=./envs/dev/backend.hcl
terraform plan -var-file=./envs/dev/terraform.tfvars
terraform apply -var-file=./envs/dev/terraform.tfvars
```

RDS:

```bash
cd ../rds
terraform init -backend-config=./envs/dev/backend.hcl
terraform plan -var-file=./envs/dev/terraform.tfvars
terraform apply -var-file=./envs/dev/terraform.tfvars
```

RDS allows MySQL `3306` only from the EKS cluster security group.

## Useful Outputs

```bash
cd terraform-petclinic-modules/ecr
terraform output repository_url

cd ../eks
terraform output kubeconfig_command

cd ../rds
terraform output jdbc_url
terraform output petclinic_db_values
```

`db_multi_az = true` creates a Multi-AZ RDS instance in one AWS region. Cross-region RDS replicas are intentionally skipped until disaster recovery is actually required.
