# 🚀 AWS 마이그레이션 작업 계획 및 분업 가이드

**프로젝트**: A계정 → B계정 인프라 마이그레이션  
**전략**: Blue-Green 배포  
**예상 기간**: 2-3주  
**작업 시간**: 업무 시간 외 권장

---

## 📋 전체 작업 순서

### Phase 1: 사전 준비 (1-2일)
### Phase 2: Import 작업 (2-3일)
### Phase 3: B계정 배포 (1-2일)
### Phase 4: 데이터 마이그레이션 (3-5일)
### Phase 5: 테스트 및 검증 (2-3일)
### Phase 6: DNS 전환 (1일)
### Phase 7: 정리 및 최적화 (1-2일)

---

## 👥 팀 구성 및 역할

### 🎯 권장 팀 구성 (3-4명)

| 역할 | 담당자 | 주요 책임 | 필요 스킬 |
|------|--------|-----------|-----------|
| **DevOps Lead** | 1명 | 전체 기술 총괄, Terraform 작업 | Terraform, AWS, 네트워킹 |
| **Backend Dev** | 1명 | 애플리케이션, 데이터베이스 | Java/Spring, MySQL, Docker |
| **Frontend Dev** | 1명 | 프론트엔드, CDN 설정 | React/Vue, CloudFront, S3 |
| **QA/PM** | 1명 | 테스트, 일정 관리, 문서화 | 테스트, 프로젝트 관리 |

### 🔄 소규모 팀 (2명)
- **DevOps + Backend**: 인프라 + 백엔드 담당
- **Frontend + QA**: 프론트엔드 + 테스트 담당

---

## 📅 Phase별 상세 작업 계획

### Phase 1: 사전 준비 (1-2일)

#### 🎯 목표
- B계정 기본 설정 완료
- Terraform 환경 구축
- 팀 권한 설정

#### 👥 분업

**DevOps Lead**:
```bash
# 1. B계정 기본 설정
- AWS 계정 생성 및 기본 설정
- IAM 사용자/역할 생성
- MFA, CloudTrail 등 보안 설정

# 2. Terraform 백엔드 설정
aws s3 mb s3://unretired-terraform-state-source --profile source-account
aws s3 mb s3://unretired-terraform-state-target --profile target-account

aws dynamodb create-table \
  --table-name unretired-terraform-locks-source \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --profile source-account

aws dynamodb create-table \
  --table-name unretired-terraform-locks-target \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --profile target-account
```

**Backend Dev**:
```bash
# 1. 현재 애플리케이션 설정 문서화
- DB 연결 문자열 정리
- 환경 변수 목록 작성
- API 엔드포인트 정리

# 2. 데이터베이스 백업 계획
- 현재 DB 스키마 덤프
- 데이터 크기 확인
- 백업 스크립트 준비
```

**Frontend Dev**:
```bash
# 1. 프론트엔드 설정 확인
- 빌드 설정 문서화
- API 엔드포인트 목록
- CDN 캐시 설정 확인

# 2. S3 버킷 데이터 크기 확인
aws s3 ls s3://dev-unretired-fe --recursive --human-readable --summarize
aws s3 ls s3://front-dev-unretired --recursive --human-readable --summarize
aws s3 ls s3://unretired-prod-abs --recursive --human-readable --summarize
```

**QA/PM**:
```bash
# 1. 테스트 계획 수립
- 기능 테스트 시나리오 작성
- 성능 테스트 기준 정의
- 사용자 승인 테스트 계획

# 2. 일정 관리
- 상세 일정표 작성
- 리스크 관리 계획
- 커뮤니케이션 계획
```

#### ✅ 완료 기준
- [ ] B계정 기본 설정 완료
- [ ] Terraform 백엔드 생성 완료
- [ ] 팀 권한 설정 완료
- [ ] 현재 시스템 문서화 완료

---

### Phase 2: Import 작업 (2-3일)

#### 🎯 목표
- A계정의 67개 리소스를 Terraform 상태로 Import
- terraform plan 변경사항 0개 달성

#### 👥 분업

**DevOps Lead** (메인 작업자):
```bash
# Day 1: 기본 인프라 Import
export AWS_PROFILE=source-account
terraform init -backend-config=environments/source/backend.conf

# VPC 및 네트워킹 (17개 리소스)
terraform import module.vpc.aws_vpc.main vpc-0a0c212e320793d21
# ... IMPORT_GUIDE.md 참조

# EC2 및 ALB (7개 리소스)
terraform import module.ec2.aws_instance.bastion i-05a543c5ed1603ba4
# ... 계속

# Day 2: 서비스 리소스 Import
# S3, RDS, CloudFront, Lambda, WAF, Route53
```

**Backend Dev** (지원):
```bash
# RDS 관련 상세 정보 수집
aws rds describe-db-instances --profile source-account
aws rds describe-db-subnet-groups --profile source-account
aws rds describe-db-parameter-groups --profile source-account

# 데이터베이스 연결 테스트
mysql -h unretired-rds.c5o64ekyqojn.ap-northeast-2.rds.amazonaws.com -u admin -p
```

**Frontend Dev** (지원):
```bash
# S3 및 CloudFront 상세 정보 수집
aws s3api get-bucket-policy --bucket front-dev-unretired --profile source-account
aws cloudfront get-distribution --id EK668CQHBMBEI --profile source-account

# CDN 캐시 상태 확인
curl -I https://cdn.unretired.co.kr/
```

**QA/PM** (모니터링):
```bash
# Import 진행 상황 추적
- 체크리스트 업데이트
- 이슈 발생 시 에스컬레이션
- 일정 관리
```

#### ✅ 완료 기준
- [ ] 67개 모든 리소스 Import 완료
- [ ] `terraform plan` 변경사항 0개 확인
- [ ] 상태 파일 백업 완료

---

### Phase 3: B계정 배포 (1-2일)

#### 🎯 목표
- B계정에 동일한 인프라 구축
- 기본 기능 동작 확인

#### 👥 분업

**DevOps Lead**:
```bash
# B계정 인프라 배포
export AWS_PROFILE=target-account
terraform init -backend-config=environments/target/backend.conf

# 단계별 배포 (의존성 순서)
terraform apply -target=module.vpc -var-file=environments/target/terraform.tfvars
terraform apply -target=module.s3 -var-file=environments/target/terraform.tfvars
terraform apply -target=module.ec2 -var-file=environments/target/terraform.tfvars
terraform apply -target=module.rds -var-file=environments/target/terraform.tfvars
# ... 계속

# 전체 배포
terraform apply -var-file=environments/target/terraform.tfvars
```

**Backend Dev**:
```bash
# B계정 키페어 생성
aws ec2 create-key-pair --key-name unretired-dev --profile target-account

# RDS 접근 테스트
# (B계정 RDS 생성 후)
mysql -h <new-rds-endpoint> -u admin -p

# 애플리케이션 설정 파일 준비
# - B계정 RDS 엔드포인트로 변경
# - B계정 S3 버킷명으로 변경
```

**Frontend Dev**:
```bash
# B계정 S3 버킷 설정 확인
aws s3api get-bucket-location --bucket <new-bucket-name> --profile target-account

# CloudFront 배포 상태 확인
aws cloudfront list-distributions --profile target-account

# 정적 파일 업로드 테스트 준비
```

**QA/PM**:
```bash
# 배포 진행 상황 모니터링
- 각 모듈별 배포 상태 확인
- 비용 사용량 모니터링
- 이슈 트래킹
```

#### ✅ 완료 기준
- [ ] B계정 모든 인프라 배포 완료
- [ ] 기본 연결성 테스트 통과
- [ ] 비용 알람 설정 완료

---

### Phase 4: 데이터 마이그레이션 (3-5일)

#### 🎯 목표
- S3 데이터 동기화
- RDS 데이터 마이그레이션
- 실시간 동기화 설정

#### 👥 분업

**DevOps Lead**:
```bash
# Day 1-2: S3 데이터 동기화
# Cross-account 복사 설정
aws s3 sync s3://dev-unretired-fe s3://dev-unretired-fe-target \
  --source-region ap-northeast-2 \
  --region ap-northeast-2 \
  --profile source-account

# 7개 버킷 모두 동기화
for bucket in dev-unretired-fe fe-dev-unretired front-dev-unretired unretired-dev-abs unretired-dev-mp4 unretired-dev-origin unretired-prod-abs; do
  aws s3 sync s3://$bucket s3://$bucket-target --profile source-account
done

# Day 3: 실시간 동기화 설정
# S3 Cross-Region Replication 또는 Lambda 기반 동기화
```

**Backend Dev**:
```bash
# Day 1: RDS 스냅샷 생성
aws rds create-db-snapshot \
  --db-instance-identifier unretired-rds \
  --db-snapshot-identifier unretired-migration-$(date +%Y%m%d) \
  --profile source-account

# Day 2: 스냅샷 공유 및 복원
aws rds modify-db-snapshot-attribute \
  --db-snapshot-identifier unretired-migration-$(date +%Y%m%d) \
  --attribute-name restore \
  --values-to-add <target-account-id> \
  --profile source-account

# B계정에서 복원
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier unretired-rds-target \
  --db-snapshot-identifier unretired-migration-$(date +%Y%m%d) \
  --profile target-account

# Day 3-4: DMS 설정 (실시간 동기화)
# AWS DMS 복제 인스턴스 생성
# 소스 및 타겟 엔드포인트 설정
# 복제 태스크 생성 및 실행

# Day 5: 애플리케이션 설정 업데이트
# B계정 리소스 정보로 설정 파일 업데이트
```

**Frontend Dev**:
```bash
# Day 1-2: 프론트엔드 빌드 및 배포
# B계정 S3 버킷에 최신 빌드 업로드
npm run build
aws s3 sync ./dist s3://front-dev-unretired-target --profile target-account

# Day 3: CloudFront 캐시 무효화 테스트
aws cloudfront create-invalidation \
  --distribution-id <new-distribution-id> \
  --paths "/*" \
  --profile target-account

# Day 4-5: CDN 설정 최적화
# 캐시 정책 확인
# Origin 설정 검증
```

**QA/PM**:
```bash
# 데이터 마이그레이션 진행 상황 모니터링
- S3 동기화 진행률 확인
- RDS 복제 상태 모니터링
- 데이터 정합성 검증 계획
- 이슈 트래킹 및 에스컬레이션
```

#### ✅ 완료 기준
- [ ] S3 데이터 100% 동기화 완료
- [ ] RDS 데이터 복제 완료
- [ ] 실시간 동기화 설정 완료
- [ ] 데이터 정합성 검증 통과

---

## 🧪 Phase 5: 테스트 및 검증 (2-3일)

#### 🎯 목표
- 모든 기능 정상 동작 확인
- 성능 기준 만족 확인
- 보안 설정 검증

#### 👥 분업

**QA/PM** (메인 작업자):
```bash
# Day 1: 기능 테스트
- 웹사이트 접근 테스트 (모든 도메인)
- 사용자 회원가입/로그인 테스트
- 비디오 업로드/재생 테스트
- API 엔드포인트 테스트

# Day 2: 성능 테스트
- 응답 시간 측정 (A계정 vs B계정)
- 동시 사용자 부하 테스트
- CDN 캐시 성능 확인
- 데이터베이스 쿼리 성능

# Day 3: 보안 테스트
- WAF 규칙 동작 확인
- SSL 인증서 검증
- 보안그룹 설정 테스트
```

**Backend Dev**:
```bash
# 백엔드 기능 테스트
- 데이터베이스 연결 확인
- API 응답 검증
- 로그 확인
- 에러 처리 테스트

# 성능 모니터링
- CloudWatch 메트릭 확인
- 애플리케이션 로그 분석
- 데이터베이스 성능 확인
```

**Frontend Dev**:
```bash
# 프론트엔드 기능 테스트
- 모든 페이지 로딩 확인
- 비디오 스트리밍 테스트
- 반응형 디자인 확인
- 브라우저 호환성 테스트

# CDN 성능 테스트
- 캐시 히트율 확인
- 글로벌 성능 테스트
- 이미지/비디오 로딩 속도
```

**DevOps Lead**:
```bash
# 인프라 모니터링
- CloudWatch 알람 설정
- 리소스 사용률 확인
- 네트워크 연결성 테스트
- 백업 및 복구 테스트
```

#### ✅ 완료 기준
- [ ] 모든 기능 테스트 통과
- [ ] 성능 기준 만족 (응답시간 < 2초)
- [ ] 보안 검증 완료
- [ ] 사용자 승인 테스트 통과

---

## 🔄 Phase 6: DNS 전환 (1일)

#### 🎯 목표
- 점진적 트래픽 전환
- 무중단 서비스 달성

#### 👥 분업 (전체 팀 참여)

**시간대별 작업** (업무 시간 외 권장):

#### 🕐 20:00 - 준비 단계
**DevOps Lead**:
```bash
# DNS TTL 사전 조정 (1시간 전)
aws route53 change-resource-record-sets \
  --change-batch file://reduce-ttl.json \
  --profile source-account
```

**전체 팀**: 대기 상태, 모니터링 준비

#### 🕘 21:00 - 10% 트래픽 전환
**DevOps Lead**:
```bash
# Route53 Weighted Routing 설정
# A계정: 90%, B계정: 10%
aws route53 change-resource-record-sets \
  --change-batch file://10-percent-traffic.json
```

**QA/PM**: 실시간 모니터링 시작
**Backend Dev**: 로그 모니터링
**Frontend Dev**: 사용자 경험 모니터링

#### 🕘 21:30 - 50% 트래픽 전환
**DevOps Lead**: 50% 트래픽 전환
**전체 팀**: 성능 지표 확인

#### 🕘 22:00 - 90% 트래픽 전환
**DevOps Lead**: 90% 트래픽 전환
**전체 팀**: 집중 모니터링

#### 🕘 22:30 - 100% 트래픽 전환
**DevOps Lead**: 100% 트래픽 전환
**전체 팀**: 최종 검증

#### 🕘 23:00 - 안정화 확인
**전체 팀**: 1시간 안정성 모니터링

#### ✅ 완료 기준
- [ ] 100% 트래픽 B계정으로 전환
- [ ] 서비스 중단 시간 < 5분
- [ ] 에러율 < 0.1%
- [ ] 응답 시간 정상 범위

---

## 📊 일일 작업 분담표

### Week 1: 준비 및 Import

| 요일 | DevOps Lead | Backend Dev | Frontend Dev | QA/PM |
|------|-------------|-------------|--------------|-------|
| **월** | B계정 설정, 백엔드 구축 | 현재 시스템 문서화 | S3 데이터 분석 | 테스트 계획 수립 |
| **화** | VPC/보안그룹 Import | RDS 백업 계획 | CDN 설정 분석 | 일정 관리 |
| **수** | EC2/ALB Import | DB 연결 테스트 | 프론트엔드 빌드 | Import 진행 모니터링 |
| **목** | S3/CloudFront Import | 애플리케이션 설정 | S3 업로드 테스트 | 이슈 트래킹 |
| **금** | Lambda/WAF/Route53 Import | 백엔드 테스트 | 프론트엔드 테스트 | 주간 리뷰 |

### Week 2: 배포 및 데이터 마이그레이션

| 요일 | DevOps Lead | Backend Dev | Frontend Dev | QA/PM |
|------|-------------|-------------|--------------|-------|
| **월** | B계정 인프라 배포 | 키페어 생성, 설정 | 빌드 배포 | 배포 모니터링 |
| **화** | S3 데이터 동기화 | RDS 스냅샷 복원 | CDN 설정 확인 | 데이터 검증 |
| **수** | 실시간 동기화 설정 | DMS 설정 | 캐시 무효화 테스트 | 진행 상황 추적 |
| **목** | 모니터링 설정 | 애플리케이션 배포 | 프론트엔드 배포 | 기능 테스트 |
| **금** | 인프라 최적화 | 백엔드 테스트 | 프론트엔드 테스트 | 주간 리뷰 |

### Week 3: 테스트 및 전환

| 요일 | DevOps Lead | Backend Dev | Frontend Dev | QA/PM |
|------|-------------|-------------|--------------|-------|
| **월** | 성능 모니터링 | API 테스트 | UI/UX 테스트 | 통합 테스트 |
| **화** | 보안 검증 | 데이터 정합성 확인 | 브라우저 테스트 | 성능 테스트 |
| **수** | DNS 전환 준비 | 백엔드 최종 점검 | 프론트엔드 최종 점검 | 사용자 승인 테스트 |
| **목** | **DNS 전환 실행** | **실시간 모니터링** | **실시간 모니터링** | **전환 총괄** |
| **금** | 안정성 확인 | 서비스 모니터링 | 사용자 피드백 수집 | 전환 완료 보고 |

---

## 🚨 비상 대응 계획

### 역할별 비상 연락망
```
DevOps Lead: 기술적 이슈 총괄
Backend Dev: 데이터베이스/API 이슈
Frontend Dev: 웹사이트/CDN 이슈  
QA/PM: 전체 조율 및 의사결정
```

### 롤백 시나리오
```bash
# 즉시 롤백 (5분 이내)
aws route53 change-resource-record-sets \
  --change-batch file://rollback-to-a-account.json

# 부분 롤백 (30분 이내)
# 특정 서비스만 A계정으로 복구

# 전체 롤백 (2시간 이내)
# 모든 트래픽 A계정으로 복구
```

---

## 📞 커뮤니케이션 계획

### 일일 스탠드업 (15분)
- **시간**: 매일 오전 9시
- **참석자**: 전체 팀
- **내용**: 진행 상황, 이슈, 당일 계획

### 주간 리뷰 (1시간)
- **시간**: 매주 금요일 오후 5시
- **참석자**: 전체 팀 + 이해관계자
- **내용**: 주간 성과, 다음 주 계획, 리스크 검토

### 비상 상황 대응
- **Slack/Teams**: 실시간 커뮤니케이션
- **전화**: 긴급 상황 시
- **화상회의**: 복잡한 이슈 논의

---

## 🎯 성공 기준

### 기술적 기준
- [ ] 서비스 중단 시간 < 5분
- [ ] 데이터 손실 0%
- [ ] 응답 시간 기존 대비 동일 수준
- [ ] 에러율 < 0.1%

### 비즈니스 기준
- [ ] 사용자 불만 최소화
- [ ] 비용 증가 < 10% (장기적)
- [ ] 마이그레이션 기간 준수
- [ ] 팀 만족도 > 80%

---

**작성자**: AWS Q Developer CLI  
**작성일**: 2025-08-22  
**버전**: 1.0
