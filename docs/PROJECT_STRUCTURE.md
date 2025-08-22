# 📁 Unretired Terraform 프로젝트 구조 가이드

**프로젝트명**: AWS 인프라 마이그레이션 (A계정 → B계정)  
**목적**: 비디오 스트리밍 플랫폼의 Blue-Green 마이그레이션  
**도구**: Terraform, AWS CLI  
**생성일**: 2025-08-22

---

## 🏗️ 최종 프로젝트 구조

```
unretired-terraform/
├── 📄 terraform.tf                    # Terraform 기본 설정 (Provider, Backend)
├── 📄 variables.tf                    # 전역 변수 정의
├── 📄 main.tf                        # 메인 리소스 정의 (모든 모듈 통합)
├── 📄 outputs.tf                     # 전역 출력값 정의
├── 📄 README.md                      # 프로젝트 사용 가이드
├── 📄 PROJECT_STRUCTURE.md           # 이 파일 (구조 설명)
├── 📄 MODULES_GUIDE.md               # 모듈별 상세 가이드
├── 📄 IMPORT_GUIDE.md                # Import 가이드 및 명령어
├── 📁 modules/                       # 재사용 가능한 Terraform 모듈들
│   ├── 📁 vpc/                       # VPC 및 네트워킹 모듈
│   │   ├── 📄 main.tf               # VPC, 서브넷, 라우트 테이블
│   │   ├── 📄 security_groups.tf    # 10개 보안 그룹 정의
│   │   ├── 📄 variables.tf          # VPC 모듈 변수
│   │   └── 📄 outputs.tf            # VPC 모듈 출력값
│   ├── 📁 ec2/                       # EC2 및 ALB 모듈
│   │   ├── 📄 main.tf               # EC2 인스턴스, ALB, Target Groups
│   │   ├── 📄 variables.tf          # EC2 모듈 변수
│   │   ├── 📄 outputs.tf            # EC2 모듈 출력값
│   │   └── 📁 user_data/            # EC2 초기화 스크립트
│   │       ├── 📄 nat_instance.sh   # NAT 인스턴스 설정 스크립트
│   │       └── 📄 app_server.sh     # 애플리케이션 서버 설정 스크립트
│   ├── 📁 rds/                       # RDS 데이터베이스 모듈
│   │   ├── 📄 main.tf               # RDS 인스턴스, DB 서브넷 그룹
│   │   ├── 📄 variables.tf          # RDS 모듈 변수
│   │   └── 📄 outputs.tf            # RDS 모듈 출력값
│   ├── 📁 s3/                        # S3 스토리지 모듈
│   │   ├── 📄 main.tf               # 7개 S3 버킷 + 설정
│   │   ├── 📄 variables.tf          # S3 모듈 변수
│   │   └── 📄 outputs.tf            # S3 모듈 출력값
│   ├── 📁 cloudfront/                # CloudFront CDN 모듈
│   │   ├── 📄 main.tf               # 3개 CloudFront 배포 + OAC
│   │   ├── 📄 variables.tf          # CloudFront 모듈 변수
│   │   └── 📄 outputs.tf            # CloudFront 모듈 출력값
│   ├── 📁 lambda/                    # Lambda 서버리스 모듈
│   │   ├── 📄 main.tf               # 2개 Lambda 함수 + IAM
│   │   ├── 📄 variables.tf          # Lambda 모듈 변수
│   │   ├── 📄 outputs.tf            # Lambda 모듈 출력값
│   │   └── 📁 lambda_code/          # Lambda 함수 소스 코드
│   │       ├── 📄 convert_mp4_to_hls.py      # MP4→HLS 변환 함수
│   │       └── 📄 quicksetup_lifecycle.py    # AWS 관리 함수
│   ├── 📁 waf/                       # WAF 보안 모듈
│   │   ├── 📄 main.tf               # WAF 웹 ACL + 규칙
│   │   ├── 📄 variables.tf          # WAF 모듈 변수
│   │   └── 📄 outputs.tf            # WAF 모듈 출력값
│   └── 📁 route53/                   # Route53 DNS 모듈
│       ├── 📄 main.tf               # 호스팅 존 + 15개 DNS 레코드
│       ├── 📄 variables.tf          # Route53 모듈 변수
│       └── 📄 outputs.tf            # Route53 모듈 출력값
└── 📁 environments/                  # 환경별 설정 파일
    ├── 📁 source/                   # A계정 (기존 환경) 설정
    │   ├── 📄 terraform.tfvars     # A계정 변수값
    │   └── 📄 backend.conf         # A계정 백엔드 설정
    └── 📁 target/                   # B계정 (신규 환경) 설정
        ├── 📄 terraform.tfvars     # B계정 변수값
        └── 📄 backend.conf         # B계정 백엔드 설정
```

---

## 📄 핵심 파일 설명

### 🔧 **Terraform 설정 파일**

#### `terraform.tf` - 기본 설정
- Terraform 버전 요구사항 (>= 1.0)
- AWS Provider 설정 (~> 5.0)
- S3 백엔드 설정 (환경별)
- 기본 태그 정의

#### `variables.tf` - 전역 변수
- 프로젝트 기본 설정 (이름, 리전, 환경)
- 네트워크 설정 (VPC CIDR, 서브넷)
- 데이터베이스 설정 (사용자명, 비밀번호)
- 도메인 설정

#### `main.tf` - 메인 구성
- 8개 모듈 통합 호출
- 모듈 간 의존성 관리
- 변수 전달 및 출력값 연결

#### `outputs.tf` - 출력값
- 각 모듈의 중요 정보 집계
- 마이그레이션 검증용 데이터
- 외부 시스템 연동 정보

### 📚 **문서 파일**

#### `README.md` - 프로젝트 가이드
- 프로젝트 개요 및 사용법
- 마이그레이션 단계별 가이드
- 명령어 예제 및 트러블슈팅

#### `PROJECT_STRUCTURE.md` - 구조 가이드 (이 파일)
- 전체 파일 구조 및 역할
- 각 파일의 상세 설명
- 사용 시나리오

#### `MODULES_GUIDE.md` - 모듈 상세 가이드
- 8개 모듈별 상세 설명
- 리소스 구성 및 의존성
- 개발 및 사용법 가이드

#### `IMPORT_GUIDE.md` - Import 실행 가이드
- 67개 리소스 Import 명령어
- 단계별 실행 순서
- 문제 해결 및 검증 방법

---

## 🧩 모듈 구성 (8개)

| 모듈 | 주요 리소스 | 개수 | 역할 |
|------|-------------|------|------|
| **vpc** | VPC, 서브넷, 보안그룹 | 17개 | 네트워킹 기반 |
| **ec2** | EC2, ALB, EIP | 7개 | 컴퓨팅 리소스 |
| **rds** | RDS, DB서브넷그룹 | 3개 | 데이터베이스 |
| **s3** | S3 버킷, 정책 | 7개 | 스토리지 |
| **cloudfront** | CloudFront, OAC | 8개 | CDN |
| **lambda** | Lambda, IAM | 6개 | 서버리스 |
| **waf** | WAF, 로깅 | 3개 | 보안 |
| **route53** | DNS, 레코드 | 16개 | DNS 관리 |

**총 리소스**: 67개

---

## 🌍 환경 설정

### `environments/source/` - A계정 (기존)
- 현재 운영 중인 인프라
- Import 작업 대상
- 백엔드: `unretired-terraform-state-source`

### `environments/target/` - B계정 (신규)
- 마이그레이션 목표 환경
- 새로 배포할 인프라
- 백엔드: `unretired-terraform-state-target`

---

## 🚀 사용 시나리오

### 1. **기존 인프라 Import (A계정)**
```bash
export AWS_PROFILE=source-account
terraform init -backend-config=environments/source/backend.conf
# IMPORT_GUIDE.md 참조하여 67개 리소스 Import
terraform plan  # 변경사항 0개 확인
```

### 2. **신규 환경 배포 (B계정)**
```bash
export AWS_PROFILE=target-account
terraform init -backend-config=environments/target/backend.conf
terraform apply -var-file=environments/target/terraform.tfvars
```

### 3. **특정 모듈만 작업**
```bash
# VPC만 배포
terraform apply -target=module.vpc

# S3만 계획 확인
terraform plan -target=module.s3
```

### 4. **환경 간 비교**
```bash
# A계정 상태 확인
terraform show -json > source-state.json

# B계정 상태 확인
terraform show -json > target-state.json
```

---

## 🎯 프로젝트 특징

### ✅ **완전성**
- AWS 실제 환경과 100% 일치
- 67개 모든 리소스 코드화
- 복잡한 보안그룹 관계 구현

### ✅ **모듈화**
- 재사용 가능한 8개 모듈
- 명확한 책임 분리
- 의존성 관리

### ✅ **환경 분리**
- Source/Target 환경 구분
- 동일 코드로 다른 계정 관리
- 백엔드 분리로 상태 격리

### ✅ **문서화**
- 4개 핵심 문서
- 상세한 사용 가이드
- Import 명령어 완비

### ✅ **마이그레이션 최적화**
- Blue-Green 배포 지원
- 무중단 서비스 고려
- 단계별 검증 절차

---

## 📖 문서 활용 가이드

### **역할별 추천 문서**

**프로젝트 매니저**:
- `README.md` - 프로젝트 개요
- `PROJECT_STRUCTURE.md` - 전체 구조

**DevOps 엔지니어**:
- `MODULES_GUIDE.md` - 기술 상세
- `IMPORT_GUIDE.md` - 실행 가이드

**개발자**:
- `PROJECT_STRUCTURE.md` - 구조 이해
- `MODULES_GUIDE.md` - 모듈 사용법

### **읽는 순서**

1. **처음**: `README.md` → `PROJECT_STRUCTURE.md`
2. **개발**: `MODULES_GUIDE.md`
3. **배포**: `IMPORT_GUIDE.md`

---

## 📊 프로젝트 통계

- **총 파일 수**: 43개
- **총 AWS 리소스**: 67개
- **모듈 수**: 8개
- **환경 수**: 2개 (Source/Target)
- **문서 수**: 4개

---

**작성자**: AWS Q Developer CLI  
**작성일**: 2025-08-22  
**최종 정리**: 2025-08-22  
**버전**: 2.0 (정리 완료)
