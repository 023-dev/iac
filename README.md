# AWS 인프라 마이그레이션 (A계정 → B계정)

**프로젝트명**: AWS 인프라 마이그레이션 (A계정 → B계정)
**목적**: 비디오 스트리밍 플랫폼의 Blue-Green 마이그레이션
**도구**: Terraform, AWS CLI
**생성일**: 2025-08-22
**최종 수정일**: 2025-11-09

---

## 1. 프로젝트 개요

이 프로젝트는 A계정에서 운영 중인 비디오 스트리밍 플랫폼의 전체 인프라를 B계정으로 마이그레이션하는 것을 목표로 합니다. Terraform을 사용하여 기존 67개의 AWS 리소스를 코드로 정의하고, Blue-Green 배포 전략을 통해 서비스 중단 없이 안전하게 이전합니다.

주요 특징은 다음과 같습니다.
- **완전성**: 실제 운영 환경의 모든 리소스를 100% 코드로 관리합니다.
- **모듈화**: 재사용 가능한 8개의 모듈로 인프라를 분리하여 관리 효율성을 높입니다.
- **환경 분리**: `source`(A계정)와 `target`(B계정) 환경을 명확히 분리하여 동일 코드로 여러 환경을 관리합니다.
- **문서화**: 상세한 실행 가이드를 통해 누구나 쉽게 프로젝트에 참여하고 작업을 수행할 수 있도록 지원합니다.

---

## 2. 빠른 시작

### 기존 인프라 Import (A계정)
```bash
# 1. A계정 자격증명 설정
export AWS_PROFILE=source-account

# 2. Terraform 초기화
terraform init -backend-config=environments/source/backend.conf

# 3. Import 실행 (상세 명령어는 docs/IMPORT_GUIDE.md 참조)
terraform import module.vpc.aws_vpc.main vpc-0a0c212e320793d21
# ... (67개 리소스 전체 Import)

# 4. 변경사항 없음 확인
terraform plan
# 예상 결과: No changes. Infrastructure is up-to-date.
```

### 신규 환경 배포 (B계정)
```bash
# 1. B계정 자격증명 설정
export AWS_PROFILE=target-account

# 2. Terraform 초기화
terraform init -backend-config=environments/target/backend.conf

# 3. 전체 인프라 배포
terraform apply -var-file=environments/target/terraform.tfvars
```

---

## 3. 프로젝트 구조

```
unretired-terraform/
├── terraform.tf                    # Terraform 기본 설정 (Provider, Backend)
├── variables.tf                    # 전역 변수 정의
├── main.tf                         # 메인 리소스 정의 (모든 모듈 통합)
├── outputs.tf                      # 전역 출력값 정의
├── README.md                       # 프로젝트 개요 및 가이드 (이 파일)
├── modules/                        # 재사용 가능한 Terraform 모듈
│   ├── vpc/                        # VPC 및 네트워킹 모듈
│   ├── ec2/                        # EC2 및 ALB 모듈
│   ├── rds/                        # RDS 데이터베이스 모듈
│   ├── s3/                         # S3 스토리지 모듈
│   ├── cloudfront/                 # CloudFront CDN 모듈
│   ├── lambda/                     # Lambda 서버리스 모듈
│   ├── waf/                        # WAF 보안 모듈
│   └── route53/                    # Route53 DNS 모듈
├── environments/                   # 환경별 설정 파일
│   ├── source/                     # A계정 (기존 환경) 설정
│   │   ├── terraform.tfvars
│   │   └── backend.conf
│   └── target/                     # B계정 (신규 환경) 설정
│       ├── terraform.tfvars
│       └── backend.conf
└── docs/                           # 상세 실행 가이드 문서
    ├── MIGRATION_WORKFLOW.md       # 전체 마이그레이션 절차 및 역할 분담
    ├── MODULES_GUIDE.md            # 각 모듈의 기술적 상세 설명
    └── IMPORT_GUIDE.md             # 리소스 Import 명령어 모음
```

---

## 4. 모듈 구성

총 8개의 모듈로 구성되어 있으며, 각 모듈은 특정 역할을 수행합니다.

| 모듈명 | 주요 리소스 | 역할 | 의존성 |
|---|---|---|---|
| **vpc** | VPC, 서브넷, 보안그룹 | 네트워킹 기반 | 없음 |
| **s3** | S3 버킷, 정책 | 스토리지 | 없음 |
| **ec2** | EC2, ALB, EIP | 컴퓨팅 리소스 | `vpc` |
| **rds** | RDS, DB서브넷그룹 | 데이터베이스 | `vpc` |
| **cloudfront** | CloudFront, OAC | CDN | `s3` |
| **lambda** | Lambda, IAM | 서버리스 | `s3` |
| **waf** | WAF, 로깅 | 보안 | `ec2` (ALB) |
| **route53** | DNS, 레코드 | DNS 관리 | `ec2`, `cloudfront` |

**배포 순서 권장:**
1. `vpc`, `s3` (병렬 가능)
2. `ec2`, `rds` (vpc 완료 후)
3. `cloudfront`, `lambda` (s3 완료 후)
4. `waf` (ec2 완료 후)
5. `route53` (모든 서비스 완료 후)

---

## 5. 마이그레이션 작업 순서 (요약)

전체 마이그레이션은 7단계로 진행됩니다.

| 단계 | 내용 | 예상 기간 |
|---|---|---|
| **Phase 1** | **사전 준비**: B계정 설정, Terraform 환경 구축, 권한 설정 | 1-2일 |
| **Phase 2** | **Import 작업**: A계정의 67개 리소스를 Terraform 코드로 가져오기 | 2-3일 |
| **Phase 3** | **B계정 배포**: B계정에 Terraform으로 인프라 전체 배포 | 1-2일 |
| **Phase 4** | **데이터 마이그레이션**: S3 및 RDS 데이터 동기화 | 3-5일 |
| **Phase 5** | **테스트 및 검증**: 기능, 성능, 보안 테스트 | 2-3일 |
| **Phase 6** | **DNS 전환**: Route53을 이용한 Blue-Green 트래픽 전환 | 1일 |
| **Phase 7** | **정리 및 최적화**: A계정 리소스 정리 및 모니터링 | 1-2일 |

---

## 6. 상세 문서

- **[마이그레이션 워크플로우](./docs/MIGRATION_WORKFLOW.md)**: 단계별 상세 작업 계획, 역할 분담, 비상 대응 계획을 포함합니다.
- **[모듈 가이드](./docs/MODULES_GUIDE.md)**: 8개 모듈 각각의 상세한 리소스 구성, 변수, 출력값 정보를 제공합니다.
- **[Import 가이드](./docs/IMPORT_GUIDE.md)**: 67개 리소스에 대한 `terraform import` 명령어 전체를 포함합니다.
