# network 실행 명령

## 사전 준비 (실 값 파일 생성)

```bash
cp envs/dev/backend.hcl.example       envs/dev/backend.hcl
cp envs/dev/terraform.tfvars.example  envs/dev/terraform.tfvars
```

## init (backend 연결, 프로바이더 다운로드)

```bash
terraform init -backend-config=envs/dev/backend.hcl -reconfigure
```

## plan (변경 미리보기, tfplan 저장)

```bash
terraform plan -var-file=envs/dev/terraform.tfvars -out=tfplan
```

## apply (저장된 tfplan 그대로 적용)

```bash
terraform apply tfplan && rm -f tfplan
```

## destroy (전체 삭제, dev 한정)

```bash
terraform destroy -var-file=envs/dev/terraform.tfvars
```

## 상태 조회

```bash
terraform state list
terraform output
terraform state show module.vpc.aws_vpc.main
```
