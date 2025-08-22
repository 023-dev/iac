# 🧩 Terraform 모듈 상세 가이드

**목적**: 각 모듈의 구조, 역할, 사용법에 대한 상세 설명  
**대상**: 개발자, DevOps 엔지니어, 시스템 관리자

---

## 📋 모듈 개요

| 모듈명 | 주요 리소스 | 의존성 | 우선순위 |
|--------|-------------|--------|----------|
| **vpc** | VPC, 서브넷, 보안그룹 | 없음 | 1 (최우선) |
| **s3** | S3 버킷, 정책 | 없음 | 2 |
| **ec2** | EC2, ALB, EIP | vpc | 3 |
| **rds** | RDS, DB서브넷그룹 | vpc | 4 |
| **cloudfront** | CloudFront, OAC | s3 | 5 |
| **lambda** | Lambda, IAM | s3 | 6 |
| **waf** | WAF, 로깅 | ec2 (ALB) | 7 |
| **route53** | DNS, 레코드 | ec2, cloudfront | 8 (최종) |

---

## 🌐 VPC 모듈 (`modules/vpc/`)

### 📁 파일 구조
```
vpc/
├── main.tf              # VPC, 서브넷, 라우팅
├── security_groups.tf   # 10개 보안그룹
├── variables.tf         # 입력 변수
└── outputs.tf          # 출력값
```

### 🎯 주요 기능
- **Multi-AZ VPC 구성**: ap-northeast-2a, 2c
- **서브넷 분리**: Public 2개, Private 2개
- **보안그룹 관리**: 10개 보안그룹 + 상호 참조
- **라우팅**: Internet Gateway, NAT Instance

### 📊 리소스 상세

#### VPC 및 네트워킹
```hcl
# VPC: 10.0.0.0/16
aws_vpc.main

# 서브넷 4개
aws_subnet.public[0]   # 10.0.0.0/20   (2a)
aws_subnet.public[1]   # 10.0.16.0/20  (2c)
aws_subnet.private[0]  # 10.0.128.0/20 (2a)
aws_subnet.private[1]  # 10.0.32.0/20  (2c)

# 라우팅
aws_internet_gateway.main
aws_route_table.public
aws_route_table.private[0]  # 2a용
aws_route_table.private[1]  # 2c용
```

#### 보안그룹 (10개)
```hcl
1. nat-instance         # NAT 인스턴스용
2. bastion-sg          # Bastion 호스트용
3. bastion-tg-sg       # Bastion Target Group용
4. ec2-rds-1           # EC2→RDS 연결용 (1)
5. rds-ec2-1           # RDS←EC2 연결용 (1)
6. ec2-rds-2           # EC2→RDS 연결용 (2)
7. rds-ec2-2           # RDS←EC2 연결용 (2)
8. rds-main            # RDS 메인 보안그룹
9. launch_wizard       # ALB용 보안그룹
```

### 🔧 사용법
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  project_name         = "unretired"
  vpc_cidr            = "10.0.0.0/16"
  availability_zones  = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnet_cidrs = ["10.0.0.0/20", "10.0.16.0/20"]
  private_subnet_cidrs = ["10.0.128.0/20", "10.0.32.0/20"]
}
```

### 📤 주요 출력값
- `vpc_id`: VPC ID
- `public_subnet_ids`: Public 서브넷 ID 리스트
- `private_subnet_ids`: Private 서브넷 ID 리스트
- `*_sg_id`: 각 보안그룹 ID

---

## 🖥️ EC2 모듈 (`modules/ec2/`)

### 📁 파일 구조
```
ec2/
├── main.tf              # EC2, ALB, EIP
├── variables.tf         # 입력 변수
├── outputs.tf          # 출력값
└── user_data/          # 초기화 스크립트
    ├── nat_instance.sh  # NAT 설정
    └── app_server.sh    # 앱 서버 설정
```

### 🎯 주요 기능
- **EC2 인스턴스 3개**: Bastion, Dev, Prod
- **Load Balancer**: ALB + Target Groups
- **네트워킹**: Elastic IP, 라우팅
- **자동화**: User Data 스크립트

### 📊 리소스 상세

#### EC2 인스턴스
```hcl
# Bastion/NAT 인스턴스
aws_instance.bastion
- Type: t2.micro
- Subnet: Public (2c)
- Security Groups: nat-instance, bastion-sg
- Features: NAT, SSH 접근점

# Development 서버
aws_instance.dev
- Type: t3.small
- Subnet: Private (2c)
- Security Groups: bastion-tg-sg, ec2-rds-1

# Production 서버
aws_instance.prod
- Type: t3.small
- Subnet: Private (2a)
- Security Groups: rds-ec2-1, bastion-tg-sg
```

#### Load Balancer
```hcl
aws_lb.main                    # ALB
aws_lb_target_group.main       # Target Group
aws_lb_target_group_attachment # Dev, Prod 연결
aws_lb_listener.main           # HTTP 리스너
```

### 🔧 사용법
```hcl
module "ec2" {
  source = "./modules/ec2"
  
  project_name            = var.project_name
  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  private_subnet_ids     = module.vpc.private_subnet_ids
  key_name               = "unretired-dev"
  
  # 보안그룹 연결
  nat_instance_sg_id = module.vpc.nat_instance_sg_id
  bastion_sg_id      = module.vpc.bastion_sg_id
  # ... 기타 보안그룹들
}
```

### 📤 주요 출력값
- `bastion_public_ip`: Bastion 공인 IP
- `alb_dns_name`: ALB DNS 이름
- `*_instance_id`: 각 인스턴스 ID

---

## 🗄️ RDS 모듈 (`modules/rds/`)

### 📁 파일 구조
```
rds/
├── main.tf         # RDS 인스턴스, DB 서브넷 그룹
├── variables.tf    # 입력 변수
└── outputs.tf     # 출력값
```

### 🎯 주요 기능
- **MySQL 8.0.40**: 관리형 데이터베이스
- **Multi-AZ 지원**: 고가용성 구성
- **보안**: 암호화, 보안그룹
- **백업**: 자동 백업 설정

### 📊 리소스 상세
```hcl
aws_db_subnet_group.main    # DB 서브넷 그룹
aws_db_instance.main        # RDS MySQL 인스턴스

# 설정
- Engine: MySQL 8.0.40
- Class: db.t4g.micro
- Storage: 20GB (최대 1TB)
- Backup: 1일 보존
- Encryption: 활성화
```

### 🔧 사용법
```hcl
module "rds" {
  source = "./modules/rds"
  
  project_name       = var.project_name
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [
    module.vpc.rds_main_sg_id,
    module.vpc.rds_ec2_1_sg_id
  ]
  
  db_username = "admin"
  db_password = var.db_password  # 민감 정보
}
```

---

## 🪣 S3 모듈 (`modules/s3/`)

### 📁 파일 구조
```
s3/
├── main.tf         # 7개 S3 버킷 + 설정
├── variables.tf    # 입력 변수
└── outputs.tf     # 출력값
```

### 🎯 주요 기능
- **7개 S3 버킷**: 용도별 분리
- **보안 설정**: Public Access Block
- **버전 관리**: 중요 버킷 버전 관리
- **CORS**: 비디오 스트리밍 지원

### 📊 버킷 구성
```hcl
# 프론트엔드 버킷
dev-unretired-fe      # 개발 프론트엔드
fe-dev-unretired      # 개발 프론트엔드 (추가)
front-dev-unretired   # 개발 프론트엔드 (메인)

# 비디오 스트리밍 버킷
unretired-dev-abs     # 개발 HLS 스트리밍
unretired-prod-abs    # 프로덕션 HLS 스트리밍
unretired-dev-mp4     # 개발 MP4 파일
unretired-dev-origin  # 개발 원본 파일
```

### 🔧 보안 설정
```hcl
# 모든 버킷에 적용
aws_s3_bucket_public_access_block
- block_public_acls = true
- block_public_policy = true
- ignore_public_acls = true
- restrict_public_buckets = true

# 비디오 버킷 CORS
aws_s3_bucket_cors_configuration
- allowed_methods = ["GET", "HEAD"]
- allowed_origins = ["*"]
- max_age_seconds = 3000
```

---

## 🌍 CloudFront 모듈 (`modules/cloudfront/`)

### 📁 파일 구조
```
cloudfront/
├── main.tf         # 3개 CloudFront 배포 + OAC
├── variables.tf    # 입력 변수
└── outputs.tf     # 출력값
```

### 🎯 주요 기능
- **3개 배포**: CDN, Frontend, Dev Frontend
- **Origin Access Control**: S3 보안 접근
- **SSL 인증서**: ACM 인증서 연결
- **캐시 최적화**: 용도별 캐시 정책

### 📊 배포 구성

#### 1. CDN 배포 (EK668CQHBMBEI)
```hcl
# 도메인: cdn.unretired.co.kr
# 용도: 비디오 스트리밍

Origins (3개):
- unretired-dev-abs    # 개발 HLS
- unretired-prod-abs   # 프로덕션 HLS  
- unretired-dev-origin # 개발 원본

Cache Behaviors (3개):
- /hls/test/* → dev-abs
- /hls/*      → prod-abs
- /api/*      → prod-abs

Security:
- Trusted Key Groups
- HTTPS Only/Redirect
```

#### 2. Frontend 배포 (ERKSR0A3VNT7I)
```hcl
# 도메인: www.unretired.co.kr
# 용도: 프론트엔드 웹사이트

Origin:
- front-dev-unretired

Features:
- SPA 지원 (403 → index.html)
- 압축 활성화
- IPv6 지원
```

#### 3. Dev Frontend 배포 (E1G6ST1NAV08MO)
```hcl
# 도메인: front.dev.unretired.co.kr
# 용도: 개발 환경 프론트엔드

Origin:
- fe-dev-unretired

Features:
- 개발 전용 도메인
- 별도 SSL 인증서
- SPA 지원
```

---

## ⚡ Lambda 모듈 (`modules/lambda/`)

### 📁 파일 구조
```
lambda/
├── main.tf              # Lambda 함수, IAM
├── variables.tf         # 입력 변수
├── outputs.tf          # 출력값
└── lambda_code/        # 소스 코드
    ├── convert_mp4_to_hls.py      # 비디오 변환
    └── quicksetup_lifecycle.py    # AWS 관리
```

### 🎯 주요 기능
- **비디오 변환**: MP4 → HLS 변환
- **AWS 관리**: QuickSetup 라이프사이클
- **IAM 관리**: 최소 권한 정책
- **로깅**: CloudWatch 통합

### 📊 함수 구성

#### 1. convert-mp4-to-hls
```python
# Runtime: Python 3.13
# Memory: 128MB
# Timeout: 3초

Environment Variables:
- S3_BUCKET_DEV_MP4
- S3_BUCKET_DEV_ABS
- S3_BUCKET_PROD_ABS
- S3_BUCKET_DEV_ORIGIN

IAM Permissions:
- S3: GetObject, PutObject, DeleteObject
- Logs: CreateLogGroup, CreateLogStream, PutLogEvents
```

#### 2. aws-quicksetup-lifecycle
```python
# Runtime: Python 3.11
# Memory: 128MB
# Timeout: 900초 (15분)

Environment Variables:
- REGION: ap-northeast-2

IAM Permissions:
- SSM 관련 권한
- CloudWatch Logs
```

---

## 🛡️ WAF 모듈 (`modules/waf/`)

### 📁 파일 구조
```
waf/
├── main.tf         # WAF 웹 ACL, 규칙
├── variables.tf    # 입력 변수
└── outputs.tf     # 출력값
```

### 🎯 주요 기능
- **웹 보안**: SQL Injection, XSS 방어
- **Rate Limiting**: DDoS 방어
- **Geo Blocking**: 국가별 차단
- **로깅**: CloudWatch 통합

### 📊 보안 규칙
```hcl
Rule 1: AWS-AWSManagedRulesCommonRuleSet
- 일반적인 웹 공격 방어
- SQL Injection, XSS 등

Rule 2: AWS-AWSManagedRulesKnownBadInputsRuleSet  
- 알려진 악성 입력 차단
- 취약점 스캐너 차단

Rule 3: Rate Limiting
- 2000 requests / 5분
- IP 기반 제한

Rule 4: Geo Blocking (선택적)
- 특정 국가 차단
- 예: 중국, 러시아
```

---

## 🌐 Route53 모듈 (`modules/route53/`)

### 📁 파일 구조
```
route53/
├── main.tf         # 호스팅 존, DNS 레코드
├── variables.tf    # 입력 변수
└── outputs.tf     # 출력값
```

### 🎯 주요 기능
- **도메인 관리**: unretired.co.kr
- **서브도메인**: 5개 서브도메인
- **SSL 검증**: ACM 인증서 검증
- **이메일**: Google Workspace 연결

### 📊 DNS 레코드 (15개)

#### 루트 도메인
```hcl
A Record: unretired.co.kr
- GitHub Pages IP (4개)

MX Record: 이메일
- Google Workspace (5개 서버)

TXT Record: 
- Google 사이트 인증
```

#### 서브도메인
```hcl
api.unretired.co.kr
- A Record (Alias) → ALB

dev.unretired.co.kr  
- A Record (Alias) → ALB

cdn.unretired.co.kr
- A Record (Alias) → CloudFront CDN
- AAAA Record (IPv6) → CloudFront CDN

www.unretired.co.kr
- A Record (Alias) → CloudFront Frontend
- AAAA Record (IPv6) → CloudFront Frontend

front.dev.unretired.co.kr
- A Record (Alias) → CloudFront Dev Frontend
- AAAA Record (IPv6) → CloudFront Dev Frontend
```

#### ACM 인증서 검증
```hcl
CNAME Records (2개):
- _86ea1dcb79a2868c45b0fcf07dcf267d.unretired.co.kr
- _6c1604354e580ab1496210707c83e2e6.dev.unretired.co.kr
```

---

## 🔄 모듈 간 의존성

### 의존성 그래프
```
vpc (기반)
├── ec2 (vpc 의존)
├── rds (vpc 의존)
└── s3 (독립)
    └── cloudfront (s3 의존)
        └── route53 (cloudfront, ec2 의존)
            └── lambda (s3 의존)
                └── waf (ec2 의존)
```

### 배포 순서
1. **vpc** + **s3** (병렬 가능)
2. **ec2** + **rds** (vpc 완료 후)
3. **cloudfront** (s3 완료 후)
4. **lambda** (s3 완료 후)
5. **waf** (ec2 완료 후)
6. **route53** (모든 서비스 완료 후)

---

## 🛠️ 개발 가이드

### 새 모듈 추가 시
1. `modules/` 하위에 디렉토리 생성
2. `main.tf`, `variables.tf`, `outputs.tf` 생성
3. 루트 `main.tf`에 모듈 호출 추가
4. 의존성 확인 및 순서 조정

### 모듈 수정 시
1. 변수 변경: `variables.tf` 수정
2. 리소스 추가: `main.tf` 수정
3. 출력값 추가: `outputs.tf` 수정
4. 문서 업데이트

### 테스트 방법
```bash
# 특정 모듈만 계획
terraform plan -target=module.vpc

# 특정 모듈만 적용
terraform apply -target=module.s3

# 의존성 그래프 확인
terraform graph | dot -Tpng > graph.png
```

---

**작성자**: AWS Q Developer CLI  
**작성일**: 2025-08-22  
**버전**: 1.0  
**총 모듈**: 8개  
**총 리소스**: 67개
