# 🚀 Unretired Infrastructure Migration

AWS 계정 간 비디오 스트리밍 플랫폼 인프라 마이그레이션을 위한 Terraform 프로젝트

## 📋 프로젝트 개요

- **목적**: A계정 → B계정 Blue-Green 마이그레이션
- **대상**: 67개 AWS 리소스 (EC2, RDS, S3, CloudFront, Lambda, WAF, Route53)
- **전략**: 무중단 서비스, 데이터 무손실
- **도구**: Terraform, AWS CLI

## 🏗️ 인프라 구성

### 현재 인프라 (A계정: 913524915414)
- **컴퓨팅**: EC2 3대, ALB 1대
- **데이터베이스**: RDS MySQL 8.0.40
- **스토리지**: S3 버킷 7개 (비디오 스트리밍용)
- **CDN**: CloudFront 배포 3개
- **보안**: WAF 웹 ACL, 보안그룹 10개
- **DNS**: Route53 (unretired.co.kr + 15개 레코드)
- **서버리스**: Lambda 함수 2개

## 🚀 빠른 시작

### 1. 사전 준비
```bash
# 저장소 클론
git clone <repository-url>
cd unretired-terraform

# AWS 자격증명 설정
aws configure --profile source-account  # A계정
aws configure --profile target-account  # B계정

# 환경 변수 설정
export TF_VAR_db_password="your-secure-password"
```

### 2. 백엔드 설정
```bash
# A계정 백엔드 생성
aws s3 mb s3://unretired-terraform-state-source --profile source-account
aws dynamodb create-table \
  --table-name unretired-terraform-locks-source \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --profile source-account

# B계정 백엔드 생성
aws s3 mb s3://unretired-terraform-state-target --profile target-account
aws dynamodb create-table \
  --table-name unretired-terraform-locks-target \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --profile target-account
```

### 3. A계정 Import (기존 인프라)
```bash
export AWS_PROFILE=source-account
terraform init -backend-config=environments/source/backend.conf

# Import 실행 (IMPORT_GUIDE.md 참조)
terraform import module.vpc.aws_vpc.main vpc-0a0c212e320793d21
# ... 67개 리소스 Import

# 검증
terraform plan  # 변경사항 0개 확인
```

### 4. B계정 배포 (신규 환경)
```bash
export AWS_PROFILE=target-account
terraform init -backend-config=environments/target/backend.conf

# 배포
terraform apply -var-file=environments/target/terraform.tfvars
```

## 📁 프로젝트 구조

```
unretired-terraform/
├── terraform.tf                 # Provider 설정
├── variables.tf                 # 전역 변수
├── main.tf                     # 모듈 통합
├── outputs.tf                  # 출력값
├── modules/                    # 8개 모듈
│   ├── vpc/                   # VPC + 보안그룹
│   ├── ec2/                   # EC2 + ALB
│   ├── rds/                   # RDS MySQL
│   ├── s3/                    # S3 버킷 7개
│   ├── cloudfront/            # CloudFront 3개
│   ├── lambda/                # Lambda 2개
│   ├── waf/                   # WAF 보안
│   └── route53/               # DNS 관리
└── environments/              # 환경별 설정
    ├── source/               # A계정 설정
    └── target/               # B계정 설정
```

## 🔧 주요 명령어

### 환경별 작업
```bash
# A계정 작업
export AWS_PROFILE=source-account
terraform init -backend-config=environments/source/backend.conf
terraform plan -var-file=environments/source/terraform.tfvars

# B계정 작업
export AWS_PROFILE=target-account
terraform init -backend-config=environments/target/backend.conf
terraform apply -var-file=environments/target/terraform.tfvars
```

### 모듈별 작업
```bash
# 특정 모듈만 배포
terraform apply -target=module.vpc
terraform apply -target=module.s3

# 특정 모듈 계획 확인
terraform plan -target=module.ec2
```

### 상태 관리
```bash
# 상태 확인
terraform show

# 상태 백업
terraform state pull > backup-$(date +%Y%m%d).json

# 리소스 목록
terraform state list
```

## 📚 상세 문서

- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)**: 전체 구조 및 파일 설명
- **[MODULES_GUIDE.md](MODULES_GUIDE.md)**: 모듈별 상세 가이드
- **[IMPORT_GUIDE.md](IMPORT_GUIDE.md)**: Import 실행 가이드

## 🚨 주의사항

### 보안
- `TF_VAR_db_password` 환경변수로 DB 비밀번호 설정
- AWS 자격증명 안전하게 관리
- 상태 파일 백업 필수

### 비용
- 마이그레이션 기간 중 약 2배 비용 발생
- 불필요한 리소스 사전 정리 권장
- 테스트 후 즉시 정리

### 안전성
- 프로덕션 작업 전 반드시 테스트
- 백업 및 롤백 계획 수립
- 업무 시간 외 작업 권장

## 🔄 마이그레이션 단계

1. **사전 준비** (1일): 백엔드 설정, 권한 확인
2. **Import** (1일): A계정 기존 인프라 가져오기
3. **배포** (1일): B계정 신규 환경 구축
4. **데이터 마이그레이션** (2-3일): S3, RDS 데이터 이전
5. **테스트** (1일): 기능 및 성능 검증
6. **DNS 전환** (1일): Blue-Green 전환
7. **정리** (1일): A계정 리소스 정리

**총 예상 기간**: 1-2주

## 🆘 문제 해결

### 일반적인 오류
- **권한 오류**: IAM 정책 확인
- **Import 실패**: 리소스 ID 재확인
- **상태 충돌**: 백업에서 복원

### 롤백 방법
```bash
# 상태 파일 복원
terraform state push backup-YYYYMMDD.json

# DNS 즉시 복구
aws route53 change-resource-record-sets --change-batch file://rollback.json
```

### 지원
- AWS 문서: [Migration Guide](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-guide/)
- Terraform 문서: [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

**작성자**: AWS Q Developer CLI  
**버전**: 2.0  
**최종 업데이트**: 2025-08-22
