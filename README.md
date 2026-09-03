# PetClinic Terraform 인프라

이 폴더는 PetClinic 서비스를 위한 Terraform 인프라를 관리합니다.

공통 Terraform 모듈은 `modules/` 폴더에 두고, 실제 배포 스택은 서비스별 폴더에서 따로 관리합니다.

```text
platform-infra/
|-- README.md
|-- WINDOWS.md
|-- network/
|   |-- backend.tf
|   |-- providers.tf
|   |-- versions.tf
|   |-- variables.tf
|   |-- main.tf
|   |-- outputs.tf
|   |-- COMMANDS.md
|   `-- envs/
|       `-- dev/
|           |-- backend.hcl.example
|           `-- terraform.tfvars.example
|-- ecr/
|   |-- backend.tf
|   |-- providers.tf
|   |-- versions.tf
|   |-- variables.tf
|   |-- main.tf
|   |-- outputs.tf
|   `-- envs/
|       `-- dev/
|           |-- backend.hcl.example
|           `-- terraform.tfvars.example
|-- eks/
|   |-- backend.tf
|   |-- providers.tf
|   |-- versions.tf
|   |-- variables.tf
|   |-- network-state.tf
|   |-- main.tf
|   |-- alb-controller-irsa.tf
|   |-- aws-load-balancer-controller-policy.json
|   |-- outputs.tf
|   `-- envs/
|       `-- dev/
|           |-- backend.hcl.example
|           `-- terraform.tfvars.example
`-- modules/
    |-- vpc/
    |   |-- variables.tf
    |   |-- main.tf
    |   `-- outputs.tf
    |-- ecr/
    |   |-- variables.tf
    |   |-- main.tf
    |   `-- outputs.tf
    `-- eks/
        |-- variables.tf
        |-- main.tf
        `-- outputs.tf
```

Windows PowerShell 환경은 [WINDOWS.md](./WINDOWS.md)를 참고합니다.

## 구성

`network`는 VPC, Subnet, NAT Gateway, Route Table 같은 네트워크 리소스를 생성합니다.

`ecr`는 PetClinic 웹/애플리케이션 이미지를 저장할 ECR Repository를 생성합니다.

`eks`는 EKS Cluster와 Managed Node Group을 생성합니다. 네트워크 정보는 `network`의 remote state를 사용합니다.

## 최초 설정

예제 파일을 한 번 복사해서 실제 설정 파일을 만듭니다.

```bash
cp network/envs/dev/backend.hcl.example network/envs/dev/backend.hcl
cp network/envs/dev/terraform.tfvars.example network/envs/dev/terraform.tfvars

cp ecr/envs/dev/backend.hcl.example ecr/envs/dev/backend.hcl
cp ecr/envs/dev/terraform.tfvars.example ecr/envs/dev/terraform.tfvars

cp eks/envs/dev/backend.hcl.example eks/envs/dev/backend.hcl
cp eks/envs/dev/terraform.tfvars.example eks/envs/dev/terraform.tfvars
```

`backend.hcl`의 S3 bucket 이름은 모든 스택에서 같은 Terraform state bucket으로 맞춥니다.

## 적용 순서

먼저 네트워크를 적용한 뒤 ECR, EKS 순서로 적용합니다.

### Network

```bash
cd network
terraform init -backend-config=./envs/dev/backend.hcl
terraform plan -var-file=./envs/dev/terraform.tfvars
terraform apply -var-file=./envs/dev/terraform.tfvars
```

### ECR

```bash
cd ../ecr
terraform init -backend-config=./envs/dev/backend.hcl
terraform plan -var-file=./envs/dev/terraform.tfvars
terraform apply -var-file=./envs/dev/terraform.tfvars
```

### EKS

```bash
cd ../eks
terraform init -backend-config=./envs/dev/backend.hcl
terraform plan -var-file=./envs/dev/terraform.tfvars
terraform apply -var-file=./envs/dev/terraform.tfvars
```

## 유용한 출력값

```bash
cd ../ecr
terraform output repository_urls

cd ../eks
terraform output kubeconfig_command
terraform output aws_load_balancer_controller_role_arn
```

`terraform.tfstate`, `terraform.tfvars`, `.terraform/` 같은 로컬 실행 파일은 Git에 올리지 않습니다.
