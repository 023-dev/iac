#!/bin/bash

# S3 데이터 마이그레이션 스크립트
# A 계정 → B 계정 데이터 복사

# 설정 (실제 프로필명으로 수정하세요)
A_ACCOUNT_PROFILE="source-account"

# 버킷 목록
BUCKETS=(
  "dev-unretired-fe"
  "fe-dev-unretired"
  "front-dev-unretired"
  "unretired-dev-abs"
  "unretired-dev-mp4"
  "unretired-dev-origin"
  "unretired-prod-abs"
)

echo "=== S3 데이터 마이그레이션 시작 ==="

# 데이터 마이그레이션
for bucket in "${BUCKETS[@]}"; do
  echo "마이그레이션: $bucket → ${bucket}-b"
  
  # 소스 버킷 존재 여부 확인
  aws s3 ls s3://$bucket --profile ${A_ACCOUNT_PROFILE} > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    echo "소스 버킷 $bucket 확인됨. 동기화 시작..."
    
    # 데이터 동기화 실행
    aws s3 sync s3://$bucket s3://${bucket}-b \
      --source-region ap-northeast-2 \
      --region ap-northeast-2 \
      --profile ${A_ACCOUNT_PROFILE}
    
    if [ $? -eq 0 ]; then
      echo "✅ $bucket → ${bucket}-b 마이그레이션 완료"
    else
      echo "❌ $bucket → ${bucket}-b 마이그레이션 실패"
    fi
  else
    echo "⚠️  소스 버킷 $bucket이 존재하지 않거나 접근 불가"
  fi
  
  echo "----------------------------------------"
done

echo ""
echo "=== 마이그레이션 완료 ==="
