# Windows PowerShell 실행 가이드

이 문서는 Windows PowerShell에서 `infra/platform-infra` Terraform 스택을 실행할 때 사용합니다.

## 최초 설정

```powershell
Copy-Item network\envs\dev\backend.hcl.example network\envs\dev\backend.hcl
Copy-Item network\envs\dev\terraform.tfvars.example network\envs\dev\terraform.tfvars

Copy-Item ecr\envs\dev\backend.hcl.example ecr\envs\dev\backend.hcl
Copy-Item ecr\envs\dev\terraform.tfvars.example ecr\envs\dev\terraform.tfvars

Copy-Item eks\envs\dev\backend.hcl.example eks\envs\dev\backend.hcl
Copy-Item eks\envs\dev\terraform.tfvars.example eks\envs\dev\terraform.tfvars
```

## 적용 순서

### Network

```powershell
Set-Location network
terraform init -backend-config=.\envs\dev\backend.hcl
terraform plan -var-file=.\envs\dev\terraform.tfvars
terraform apply -var-file=.\envs\dev\terraform.tfvars
```

### ECR

```powershell
Set-Location ..\ecr
terraform init -backend-config=.\envs\dev\backend.hcl
terraform plan -var-file=.\envs\dev\terraform.tfvars
terraform apply -var-file=.\envs\dev\terraform.tfvars
```

### EKS

```powershell
Set-Location ..\eks
terraform init -backend-config=.\envs\dev\backend.hcl
terraform plan -var-file=.\envs\dev\terraform.tfvars
terraform apply -var-file=.\envs\dev\terraform.tfvars
```

## 유용한 출력값

```powershell
Set-Location ..\ecr
terraform output repository_url

Set-Location ..\eks
terraform output kubeconfig_command
terraform output aws_load_balancer_controller_role_arn
```
