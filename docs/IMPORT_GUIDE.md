# Terraform Import 가이드

**목적**: A계정의 기존 AWS 리소스를 Terraform 상태로 가져오기
**전략**: 의존성 순서에 따른 단계별 Import
**검증**: terraform plan으로 변경사항 0개 확인

---

## Import 전략

### 1. 사전 준비
```bash
# A계정 자격증명 설정
export AWS_PROFILE=source-account

# Terraform 초기화
terraform init -backend-config=environments/source/backend.conf

# 변수 파일 확인
export TF_VAR_db_password="your-secure-password"
```

### 2. Import 순서
1. **VPC 및 네트워킹** (기반 인프라)
2. **보안 그룹** (상호 참조 관계)
3. **S3 버킷** (독립적)
4. **EC2 인스턴스** (VPC 의존)
5. **RDS 데이터베이스** (VPC 의존)
6. **CloudFront 배포** (S3 의존)
7. **Lambda 함수** (독립적)
8. **WAF 웹 ACL** (독립적)
9. **Route53 DNS** (모든 서비스 의존)

---

## Phase 1: VPC 및 네트워킹

### VPC 기본 리소스
```bash
# VPC
terraform import module.vpc.aws_vpc.main vpc-0a0c212e320793d21

# Internet Gateway
terraform import module.vpc.aws_internet_gateway.main igw-034ea3c241efd1c9b

# 서브넷 4개
terraform import 'module.vpc.aws_subnet.public[0]' subnet-0e794bef748206ac2
terraform import 'module.vpc.aws_subnet.public[1]' subnet-042cd2f47b92e94bf
terraform import 'module.vpc.aws_subnet.private[0]' subnet-0d0ad21b8accdcd2a
terraform import 'module.vpc.aws_subnet.private[1]' subnet-0b347ad9860c7635b

# 라우트 테이블
terraform import 'module.vpc.aws_route_table.public' rtb-07684620ea725e36d
terraform import 'module.vpc.aws_route_table.private[0]' rtb-0c4f6a55bd75e335b
terraform import 'module.vpc.aws_route_table.private[1]' rtb-0bdfc9363a7645d28

# 라우트 테이블 연결
terraform import 'module.vpc.aws_route_table_association.public[0]' subnet-0e794bef748206ac2/rtb-07684620ea725e36d
terraform import 'module.vpc.aws_route_table_association.public[1]' subnet-042cd2f47b92e94bf/rtb-07684620ea725e36d
terraform import 'module.vpc.aws_route_table_association.private[0]' subnet-0d0ad21b8accdcd2a/rtb-0c4f6a55bd75e335b
terraform import 'module.vpc.aws_route_table_association.private[1]' subnet-0b347ad9860c7635b/rtb-0bdfc9363a7645d28
```

### 보안 그룹 (10개)
```bash
# 1. NAT Instance
terraform import module.vpc.aws_security_group.nat_instance sg-063353eb24d716c15

# 2. Bastion
terraform import module.vpc.aws_security_group.bastion sg-0882b29082c48255b

# 3. Bastion Target Group
terraform import module.vpc.aws_security_group.bastion_tg sg-06930983098cc34d2

# 4. EC2 to RDS (1)
terraform import module.vpc.aws_security_group.ec2_rds_1 sg-074a9c34f5484c4e4

# 5. RDS from EC2 (1)
terraform import module.vpc.aws_security_group.rds_ec2_1 sg-0bc06d4b192937baa

# 6. EC2 to RDS (2)
terraform import module.vpc.aws_security_group.ec2_rds_2 sg-0b36c50214409f1da

# 7. RDS from EC2 (2)
terraform import module.vpc.aws_security_group.rds_ec2_2 sg-0cf43a110dd377a0b

# 8. RDS Main
terraform import module.vpc.aws_security_group.rds_main sg-01297719a0b1000e7

# 9. Launch Wizard (ALB용)
terraform import module.vpc.aws_security_group.launch_wizard sg-0ddcbea3e398c7a6c
```

### 검증
```bash
# 결과: No changes. Infrastructure is up-to-date.
```

---

## Phase 2: S3 버킷

### S3 버킷 (7개)
```bash
# 프론트엔드 버킷
terraform import module.s3.aws_s3_bucket.dev_unretired_fe dev-unretired-fe
terraform import module.s3.aws_s3_bucket.fe_dev_unretired fe-dev-unretired
terraform import module.s3.aws_s3_bucket.front_dev_unretired front-dev-unretired

# 비디오 스트리밍 버킷
terraform import module.s3.aws_s3_bucket.unretired_dev_abs unretired-dev-abs
terraform import module.s3.aws_s3_bucket.unretired_dev_mp4 unretired-dev-mp4
terraform import module.s3.aws_s3_bucket.unretired_dev_origin unretired-dev-origin
terraform import module.s3.aws_s3_bucket.unretired_prod_abs unretired-prod-abs
```

### S3 버킷 설정
```bash
# 버전 관리 (선택적 버킷만)
terraform import module.s3.aws_s3_bucket_versioning.dev_unretired_fe dev-unretired-fe
terraform import module.s3.aws_s3_bucket_versioning.front_dev_unretired front-dev-unretired

# Public Access Block (모든 버킷)
terraform import module.s3.aws_s3_bucket_public_access_block.dev_unretired_fe dev-unretired-fe
terraform import module.s3.aws_s3_bucket_public_access_block.fe_dev_unretired fe-dev-unretired
terraform import module.s3.aws_s3_bucket_public_access_block.front_dev_unretired front-dev-unretired
terraform import module.s3.aws_s3_bucket_public_access_block.unretired_dev_abs unretired-dev-abs
terraform import module.s3.aws_s3_bucket_public_access_block.unretired_dev_mp4 unretired-dev-mp4
terraform import module.s3.aws_s3_bucket_public_access_block.unretired_dev_origin unretired-dev-origin
terraform import module.s3.aws_s3_bucket_public_access_block.unretired_prod_abs unretired-prod-abs

# CORS 설정 (비디오 버킷만)
terraform import module.s3.aws_s3_bucket_cors_configuration.unretired_dev_abs unretired-dev-abs
terraform import module.s3.aws_s3_bucket_cors_configuration.unretired_prod_abs unretired-prod-abs
```

### 검증
```bash
terraform plan -target=module.s3
# 결과: No changes. Infrastructure is up-to-date.
```

---

## Phase 3: EC2 인스턴스

### EC2 인스턴스 (3개)
```bash
# Bastion/NAT 인스턴스
terraform import module.ec2.aws_instance.bastion i-05a543c5ed1603ba4

# Development 서버
terraform import module.ec2.aws_instance.dev i-01f451fd44e52d284

# Production 서버
terraform import module.ec2.aws_instance.prod i-075e79a48e1bae776
```

### Elastic IP
```bash
# Bastion용 EIP
terraform import module.ec2.aws_eip.bastion eipalloc-xxxxxxxxx
```

### ALB 및 Target Groups
```bash
# Application Load Balancer
terraform import module.ec2.aws_lb.main arn:aws:elasticloadbalancing:ap-northeast-2:913524915414:loadbalancer/app/unretired-prod-alb/537dd3e1924c3dd0

# Target Group
terraform import module.ec2.aws_lb_target_group.main arn:aws:elasticloadbalancing:ap-northeast-2:913524915414:targetgroup/unretired-tg/xxxxxxxxx

# Target Group Attachments
terraform import module.ec2.aws_lb_target_group_attachment.dev arn:aws:elasticloadbalancing:ap-northeast-2:913524915414:targetgroup/unretired-tg/xxxxxxxxx/i-01f451fd44e52d284
terraform import module.ec2.aws_lb_target_group_attachment.prod arn:aws:elasticloadbalancing:ap-northeast-2:913524915414:targetgroup/unretired-tg/xxxxxxxxx/i-075e79a48e1bae776

# ALB Listener
terraform import module.ec2.aws_lb_listener.main arn:aws:elasticloadbalancing:ap-northeast-2:913524915414:listener/app/unretired-prod-alb/537dd3e1924c3dd0/xxxxxxxxx
```

### 라우팅 (NAT)
```bash
# Private 서브넷 NAT 라우팅
terraform import 'module.ec2.aws_route.private_nat[0]' rtb-xxxxxxxxx_0.0.0.0/0
terraform import 'module.ec2.aws_route.private_nat[1]' rtb-xxxxxxxxx_0.0.0.0/0
```

### 검증
```bash
terraform plan -target=module.ec2
# 결과: No changes. Infrastructure is up-to-date.
```

---

## Phase 4: RDS 데이터베이스

### RDS 리소스
```bash
# DB 서브넷 그룹
terraform import module.rds.aws_db_subnet_group.main default-vpc-0a0c212e320793d21

# RDS 인스턴스
terraform import module.rds.aws_db_instance.main unretired-rds
```

### 검증
```bash
terraform plan -target=module.rds
# 결과: No changes. Infrastructure is up-to-date.
```

---

## Phase 5: CloudFront 배포

### Origin Access Control
```bash
# OAC 5개 (실제 ID 확인 필요)
terraform import module.cloudfront.aws_cloudfront_origin_access_control.dev_abs E30758SVAALR6S
terraform import module.cloudfront.aws_cloudfront_origin_access_control.prod_abs E3TKWWVKSH3SNS
terraform import module.cloudfront.aws_cloudfront_origin_access_control.dev_origin E31P4SP8SRVWAO
terraform import module.cloudfront.aws_cloudfront_origin_access_control.front_dev E3L4HOE5RXOBTU
terraform import module.cloudfront.aws_cloudfront_origin_access_control.fe_dev EUVHEIMRHMFQV
```

### CloudFront 배포 (3개)
```bash
# CDN 배포 (비디오 스트리밍)
terraform import module.cloudfront.aws_cloudfront_distribution.cdn EK668CQHBMBEI

# Frontend 배포 (www)
terraform import module.cloudfront.aws_cloudfront_distribution.frontend ERKSR0A3VNT7I

# Dev Frontend 배포 (front.dev)
terraform import module.cloudfront.aws_cloudfront_distribution.dev_frontend E1G6ST1NAV08MO
```

### 검증
```bash
terraform plan -target=module.cloudfront
# 결과: No changes. Infrastructure is up-to-date.
```

---

## Phase 6: Lambda 함수

### IAM 역할
```bash
# convert-mp4-to-hls 역할
terraform import module.lambda.aws_iam_role.convert_mp4_to_hls_role convert-mp4-to-hls-role-v90p5sxo

# QuickSetup 역할
terraform import module.lambda.aws_iam_role.quicksetup_lifecycle_role AWS-QuickSetup-SSM-LifecycleManagement-LA-ap-northeast-2
```

### IAM 정책
```bash
# convert-mp4-to-hls 정책
terraform import module.lambda.aws_iam_role_policy.convert_mp4_to_hls_policy convert-mp4-to-hls-role-v90p5sxo:convert-mp4-to-hls-policy
```

### CloudWatch 로그 그룹
```bash
# convert-mp4-to-hls 로그
terraform import module.lambda.aws_cloudwatch_log_group.convert_mp4_to_hls /aws/lambda/convert-mp4-to-hls

# QuickSetup 로그
terraform import module.lambda.aws_cloudwatch_log_group.quicksetup_lifecycle /aws/lambda/aws-quicksetup-lifecycle-LA-cptq3
```

### Lambda 함수
```bash
# convert-mp4-to-hls 함수
terraform import module.lambda.aws_lambda_function.convert_mp4_to_hls convert-mp4-to-hls

# QuickSetup 함수
terraform import module.lambda.aws_lambda_function.quicksetup_lifecycle aws-quicksetup-lifecycle-LA-cptq3
```

### 검증
```bash
terraform plan -target=module.lambda
# 결과: No changes. Infrastructure is up-to-date.
```

---

## Phase 7: WAF 웹 ACL

### WAF 리소스
```bash
# CloudWatch 로그 그룹
terraform import module.waf.aws_cloudwatch_log_group.waf_log_group /aws/wafv2/unretired-prod-waf

# WAF 웹 ACL
terraform import module.waf.aws_wafv2_web_acl.unretired_prod 54e15a86-d588-413f-b68b-3898ef7435de/unretired-prod-waf/REGIONAL

# WAF 로깅 설정
terraform import module.waf.aws_wafv2_web_acl_logging_configuration.unretired_prod arn:aws:wafv2:ap-northeast-2:913524915414:regional/webacl/unretired-prod-waf/54e15a86-d588-413f-b68b-3898ef7435de

# WAF-ALB 연결 (있는 경우)
terraform import module.waf.aws_wafv2_web_acl_association.alb_association arn:aws:wafv2:ap-northeast-2:913524915414:regional/webacl/unretired-prod-waf/54e15a86-d588-413f-b68b-3898ef7435de,arn:aws:elasticloadbalancing:ap-northeast-2:913524915414:loadbalancer/app/unretired-prod-alb/537dd3e1924c3dd0
```

### 검증
```bash
terraform plan -target=module.waf
# 결과: No changes. Infrastructure is up-to-date.
```

---

## Phase 8: Route53 DNS

### 호스팅 존
```bash
# 호스팅 존
terraform import module.route53.aws_route53_zone.main Z08813753QBUC7KJUJLYK
```

### DNS 레코드 (15개)
```bash
# 루트 도메인 A 레코드
terraform import module.route53.aws_route53_record.root_a Z08813753QBUC7KJUJLYK_unretired.co.kr_A

# MX 레코드
terraform import module.route53.aws_route53_record.mx Z08813753QBUC7KJUJLYK_unretired.co.kr_MX

# TXT 레코드
terraform import module.route53.aws_route53_record.google_verification Z08813753QBUC7KJUJLYK_unretired.co.kr_TXT

# ACM 검증 CNAME 레코드
terraform import module.route53.aws_route53_record.acm_validation_root Z08813753QBUC7KJUJLYK__86ea1dcb79a2868c45b0fcf07dcf267d.unretired.co.kr_CNAME
terraform import module.route53.aws_route53_record.acm_validation_dev Z08813753QBUC7KJUJLYK__6c1604354e580ab1496210707c83e2e6.dev.unretired.co.kr_CNAME

# API 서브도메인 (ALB)
terraform import module.route53.aws_route53_record.api Z08813753QBUC7KJUJLYK_api.unretired.co.kr_A

# Dev 서브도메인 (ALB)
terraform import module.route53.aws_route53_record.dev Z08813753QBUC7KJUJLYK_dev.unretired.co.kr_A

# CDN 서브도메인 (CloudFront)
terraform import module.route53.aws_route53_record.cdn_a Z08813753QBUC7KJUJLYK_cdn.unretired.co.kr_A
terraform import module.route53.aws_route53_record.cdn_aaaa Z08813753QBUC7KJUJLYK_cdn.unretired.co.kr_AAAA

# WWW 서브도메인 (CloudFront)
terraform import module.route53.aws_route53_record.www_a Z08813753QBUC7KJUJLYK_www.unretired.co.kr_A
terraform import module.route53.aws_route53_record.www_aaaa Z08813753QBUC7KJUJLYK_www.unretired.co.kr_AAAA

# Dev Frontend 서브도메인 (CloudFront)
terraform import module.route53.aws_route53_record.front_dev_a Z08813753QBUC7KJUJLYK_front.dev.unretired.co.kr_A
terraform import module.route53.aws_route53_record.front_dev_aaaa Z08813753QBUC7KJUJLYK_front.dev.unretired.co.kr_AAAA
```

### 검증
```bash
terraform plan -target=module.route53
# 결과: No changes. Infrastructure is up-to-date.
```

---

## 최종 검증

### 전체 계획 확인
```bash
terraform plan
# 예상 결과: No changes. Infrastructure is up-to-date.
```

### 상태 파일 백업
```bash
# 상태 파일 백업
terraform state pull > terraform-state-backup-$(date +%Y%m%d-%H%M%S).json

# S3에 추가 백업
aws s3 cp terraform-state-backup-*.json s3://unretired-terraform-state-source/backups/
```

### 출력값 확인
```bash
terraform output
```

---

## 문제 해결

### 일반적인 Import 오류

#### 1. 리소스 ID 불일치
```bash
# 오류: Resource not found
# 해결: AWS CLI로 실제 ID 확인
aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId'
```

#### 2. 의존성 오류
```bash
# 오류: Resource depends on another resource
# 해결: 의존성 순서대로 Import
terraform import module.vpc.aws_vpc.main vpc-xxx  # 먼저
terraform import module.ec2.aws_instance.bastion i-xxx  # 나중에
```

#### 3. 상태 충돌
```bash
# 오류: Resource already exists in state
# 해결: 상태에서 제거 후 다시 Import
terraform state rm module.vpc.aws_vpc.main
terraform import module.vpc.aws_vpc.main vpc-xxx
```

#### 4. 권한 오류
```bash
# 오류: Access denied
# 해결: IAM 권한 확인
aws sts get-caller-identity
aws iam get-user
```

### Import 실패 시 롤백
```bash
# 상태 파일 복원
terraform state push terraform-state-backup-YYYYMMDD-HHMMSS.json

# 또는 특정 리소스만 제거
terraform state rm module.problematic_module.resource_name
```

---

## Import 진행 체크리스트

### Phase 1: VPC
- [ ] VPC
- [ ] Internet Gateway
- [ ] 서브넷 4개
- [ ] 라우트 테이블 3개
- [ ] 라우트 테이블 연결 4개
- [ ] 보안그룹 10개

### Phase 2: S3
- [ ] S3 버킷 7개
- [ ] 버전 관리 설정
- [ ] Public Access Block 7개
- [ ] CORS 설정 2개

### Phase 3: EC2
- [ ] EC2 인스턴스 3개
- [ ] Elastic IP 1개
- [ ] ALB 1개
- [ ] Target Group 1개
- [ ] Target Group Attachments 2개
- [ ] ALB Listener 1개
- [ ] NAT 라우팅 2개

### Phase 4: RDS
- [ ] DB 서브넷 그룹 1개
- [ ] RDS 인스턴스 1개

### Phase 5: CloudFront
- [ ] Origin Access Control 5개
- [ ] CloudFront 배포 3개

### Phase 6: Lambda
- [ ] IAM 역할 2개
- [ ] IAM 정책 1개
- [ ] CloudWatch 로그 그룹 2개
- [ ] Lambda 함수 2개

### Phase 7: WAF
- [ ] CloudWatch 로그 그룹 1개
- [ ] WAF 웹 ACL 1개
- [ ] WAF 로깅 설정 1개
- [ ] WAF-ALB 연결 1개

### Phase 8: Route53
- [ ] 호스팅 존 1개
- [ ] DNS 레코드 15개

### 최종 검증
- [ ] terraform plan (변경사항 0개)
- [ ] 상태 파일 백업
- [ ] 출력값 확인
