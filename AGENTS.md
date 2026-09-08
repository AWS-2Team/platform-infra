# AGENTS.md

이 저장소는 Terraform 으로 AWS 인프라를 관리하는 IaC 저장소입니다. AI 에이전트가 작업할 때 아래 규칙을 지킵니다.

## 이 저장소

- `modules/`: 재사용 모듈 (`vpc`, `ecr`, `iam`, `eks`).
- `00-network`, `01-ecr`, `02-iam`, `03-eks`: 레이어 루트. 앞 번호가 배포 순서이고 각자 S3 상태를 가집니다.
- 배포 순서와 명령은 `README.md` 에 있습니다.

## 규칙

### 1. 목적을 잊지 않는다 (가장 중요)

Terraform 의 목적은 인프라를 프로비저닝하고 코드로 관리하는 것입니다. 기술적으로 "가능한 것"과 이 저장소에서 "해야 하는 것"은 다릅니다. 목적에서 벗어난 기능을 Terraform 으로 구현하지 않습니다. 판단이 서지 않으면 만들지 말고 물어봅니다.

### 2. 요청한 것만, 하나씩 만든다

사용자가 이번 요청에서 명시한 리소스만 만듭니다. 요청하지 않은 것을 스스로 덧붙이지 않습니다.

- 예: ECR 을 요청받으면 ECR 만 만듭니다. GitHub 연동, IAM 역할, 실행 스크립트, 부가 정책 같은 것은 사용자가 따로 요청하기 전에는 만들지 않습니다.
- 판단 기준: 그 리소스가 사용자의 이번 요청 문장에 있는가. 없으면 만들지 않습니다. 필요해 보여도 먼저 물어보고, 승인 전에는 만들지 않습니다.

### 3. 리소스 이름과 주소는 한번 정하면 바꾸지 않는다

이미 만든 리소스의 Terraform 주소(예: `aws_ecr_repository.app`)와 이름을 수정하지 않습니다. 주소를 바꾸면 Terraform 이 기존 자원을 삭제하고 새로 만듭니다(destroy 후 recreate). 데이터 손실과 재생성의 원인입니다.

- 이름 변경이 정말 불가피하면 그냥 rename 하지 말고 `moved` 블록으로 처리하며, 실행 전에 사용자에게 먼저 알립니다.

### 4. 최소로 구성한다

모르는 부분을 넓게 잡아 크게 설계하지 않습니다. 이번 요청에 필요한 최소 구성만 만듭니다. 넓은 추측 설명 대신, 확인된 최소 범위만 다룹니다. 작업 시 ponytail 스킬을 사용합니다.

ponytail 스킬 설치 (Claude Code):

```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
```

### 5. AWS 자격증명은 프로필로만 사용한다

AWS 자격증명(액세스 키, 세션 토큰 등)을 환경변수나 도구로 직접 읽거나 다루지 않습니다. `~/.aws` 의 자격증명을 조회하거나 추출하지 않고, 이름 지정된 프로필(예: `AWS_PROFILE=tf-user`)로만 지정해서 사용합니다.

### 6. 억지로 목적을 이루지 않는다

목적을 달성하려고 우회나 편법을 쓰지 않습니다. 정공법으로 안 되면 멈추고 사용자에게 알립니다.

### 7. 구성 전에 목적을 확인하고 검토한다

무언가를 만들고 싶을 때, 먼저 그게 왜 필요한지 목적을 사용자에게 묻습니다. 브레인스토밍 스킬(superpowers)로 정말 필요한 기능인지 검토한 뒤에 만듭니다. 검토 없이 바로 구성하지 않습니다.

### 8. 시크릿을 GitHub 에 올리지 않는다

`.env` 와 env 계열 파일, AWS 자격증명은 GitHub 에 커밋하거나 푸시하지 않습니다. `.gitignore` 로 무시하고, `.githooks/pre-commit` 훅이 커밋 단계에서 차단합니다.

훅 활성화 (클론 후 한 번):

```
git config core.hooksPath .githooks
```

### 9. 레이어 디렉터리는 배포 순서대로 번호를 붙인다

레이어 루트는 `NN-<이름>`(예: `00-network`, `01-ecr`, `02-iam`, `03-eks`)으로 만들고 앞 번호가 배포 순서입니다. 새 레이어를 추가하면 의존성에 맞는 번호를 붙이고, 배포 순서와 명령을 `README.md` 에 갱신합니다.

### 10. 새 모듈과 레이어는 vpc 규약을 따른다

`modules/vpc` 와 `00-network` 를 기준으로 통일합니다. 혼자 다른 규격으로 만들지 않습니다.

- 이름: 루트에서 `local.name_prefix = "<project>-<env>"` 를 만들어 모듈에 `name` 으로 넘기고, 모듈은 `<name>-<suffix>` 로 조립합니다. 전체 이름을 하드코딩하지 않습니다.
- 값: 구체값(리소스 목록, 크기 등)은 tfvars 에 두고 `main.tf` 는 변수만 넘깁니다. main.tf 에 값을 하드코딩하지 않습니다.
- 태그: 모듈은 `Name` 만 지정하고 `Environment`, `Project`, `ManagedBy` 는 provider `default_tags` 로 자동 적용합니다.
- backend: 빈 `backend "s3" {}` 에 `envs/<env>/backend.hcl` 을 주입합니다. 키는 `<project>/<env>/<layer>/terraform.tfstate` 형식입니다.
- versions: `required_version` 과 provider 버전을 다른 레이어와 맞춥니다.
