# PetClinic Terraform 인프라

PetClinic 서비스를 위한 Terraform 인프라를 관리합니다.

공통 모듈은 `modules/` 에 두고, 실제 배포 스택은 레이어별 폴더에서 관리합니다. 폴더 앞 번호가 배포 순서입니다.

```text
platform-infra/
|-- README.md
|-- WINDOWS.md
|-- 00-network/      # VPC, subnet, NAT, bastion
|-- 01-ecr/          # 컨테이너 이미지 저장소
|-- 02-iam/          # GitHub OIDC 공급자 + CI 역할
|-- 03-eks/          # EKS 클러스터, 노드, ALB 컨트롤러
`-- modules/
    |-- vpc/
    |-- ecr/
    |-- iam/
    `-- eks/
```

각 레이어는 `backend.tf`, `providers.tf`, `versions.tf`, `variables.tf`, `main.tf` 와 `envs/<env>/` 를 가집니다. Windows PowerShell 환경은 [WINDOWS.md](./WINDOWS.md) 를 참고합니다.

## 구성

- `00-network`: VPC, Subnet, NAT Gateway, Route Table, bastion.
- `01-ecr`: PetClinic 웹/애플리케이션 이미지를 저장할 ECR Repository.
- `02-iam`: GitHub Actions 가 키 없이 AWS 에 접근하는 OIDC 공급자와 CI 역할.
- `03-eks`: EKS Cluster 와 Managed Node Group. 네트워크 정보는 `00-network` 의 remote state 를 사용합니다.

## 최초 설정

레이어마다 예제를 복사해 실제 값을 채웁니다. 00-network / 01-ecr / 03-eks 는 `envs/dev/`, 02-iam 도 `envs/dev/` 입니다.

```bash
cp envs/dev/backend.hcl.example       envs/dev/backend.hcl
cp envs/dev/terraform.tfvars.example  envs/dev/terraform.tfvars
```

`backend.hcl` 의 S3 bucket 은 모든 레이어에서 같은 dev state bucket 으로 맞춥니다. 자격증명은 로컬에서 `export AWS_PROFILE=<본인_프로필>` 로 줍니다.

## 배포 순서

낮은 번호부터 적용합니다. 의존성 때문에 순서가 중요합니다.

| 순서 | 레이어 | 의존 |
| --- | --- | --- |
| 00 | network | 없음 |
| 01 | ecr | 없음 |
| 02 | iam | ecr (역할 ECR 권한이 repo 참조 시) |
| 03 | eks | network |

각 레이어에서 다음을 실행합니다.

```bash
cd <레이어>
terraform init  -backend-config=envs/dev/backend.hcl -reconfigure
terraform plan  -var-file=envs/dev/terraform.tfvars -out=tfplan
terraform apply tfplan
```

삭제는 역순(03 -> 00)으로 합니다.

## 유용한 출력값

```bash
cd 01-ecr
terraform output repository_urls

cd ../02-iam
terraform output role_arns

cd ../03-eks
terraform output kubeconfig_command
```

`terraform.tfstate`, `terraform.tfvars`, `backend.hcl`, `.terraform/`, `.env` 같은 로컬/시크릿 파일은 Git 에 올리지 않습니다.
