# PetClinic Terraform 인프라

이 저장소는 PetClinic 서비스를 위한 Terraform 인프라를 관리합니다.

공통 Terraform 모듈은 루트 `modules/` 폴더에 두고, 실제 배포 스택은 서비스별 폴더에서 따로 관리합니다. 이렇게 하면 VPC, ECR, EKS 같은 리소스의 역할을 나누고 Terraform state도 분리해서 사용할 수 있습니다.

```text
platform-infra/
  modules/
    vpc/
    ecr/
    eks/
  network/
  terraform-petclinic-modules/
    ecr/
      envs/dev/backend.hcl
      envs/dev/terraform.tfvars
    eks/
      envs/dev/backend.hcl
      envs/dev/terraform.tfvars
    envs/
```

## 구성

`network`는 VPC, Subnet, NAT Gateway, Route Table 같은 네트워크 리소스를 생성합니다.

`modules/ecr`는 PetClinic 애플리케이션 이미지를 저장할 ECR Repository 모듈입니다.

`modules/eks`는 EKS Cluster와 Managed Node Group을 생성하는 모듈입니다. 네트워크 정보는 `network`의 remote state를 사용합니다.

`terraform-petclinic-modules/ecr`와 `terraform-petclinic-modules/eks`는 각 모듈을 실제 dev 환경에 적용하기 위한 root stack입니다.

## 최초 설정

예제 파일을 한 번 복사해서 실제 설정 파일을 만듭니다.

```powershell
Copy-Item terraform-petclinic-modules\ecr\envs\dev\backend.hcl.example terraform-petclinic-modules\ecr\envs\dev\backend.hcl
Copy-Item terraform-petclinic-modules\ecr\envs\dev\terraform.tfvars.example terraform-petclinic-modules\ecr\envs\dev\terraform.tfvars

Copy-Item terraform-petclinic-modules\eks\envs\dev\backend.hcl.example terraform-petclinic-modules\eks\envs\dev\backend.hcl
Copy-Item terraform-petclinic-modules\eks\envs\dev\terraform.tfvars.example terraform-petclinic-modules\eks\envs\dev\terraform.tfvars
```

`backend.hcl`의 S3 bucket 이름은 `network`에서 사용하는 Terraform state bucket과 동일하게 맞춥니다.

## 적용 순서

먼저 네트워크를 적용한 뒤 ECR, EKS 순서로 적용합니다.

### ECR

```powershell
cd terraform-petclinic-modules\ecr
terraform init -backend-config=.\envs\dev\backend.hcl
terraform plan -var-file=.\envs\dev\terraform.tfvars
terraform apply -var-file=.\envs\dev\terraform.tfvars
```

### EKS

```powershell
cd ..\eks
terraform init -backend-config=.\envs\dev\backend.hcl
terraform plan -var-file=.\envs\dev\terraform.tfvars
terraform apply -var-file=.\envs\dev\terraform.tfvars
```

## 유용한 출력값

```powershell
cd terraform-petclinic-modules\ecr
terraform output repository_url

cd ..\eks
terraform output kubeconfig_command
```

`terraform.tfstate`, `terraform.tfvars`, `.terraform/` 같은 로컬 실행 파일은 Git에 올리지 않습니다.
