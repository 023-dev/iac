# 환경
export AWS_PROFILE=target
export AWS_REGION=ap-northeast-2

# TF 출력값 로드
RI_ARN=$(terraform output -raw replication_instance_arn)
SRC_ARN=$(terraform output -raw source_endpoint_arn)
TGT_ARN=$(terraform output -raw target_endpoint_arn)
TASK_ARN=$(aws dms describe-replication-tasks \
  --filters Name=replication-task-id,Values=unretired-rds-dms-task \
  --query 'ReplicationTasks[0].ReplicationTaskArn' --output text)

# 테스트 kick
aws dms test-connection --replication-instance-arn "$RI_ARN" --endpoint-arn "$SRC_ARN" >/dev/null
aws dms test-connection --replication-instance-arn "$RI_ARN" --endpoint-arn "$TGT_ARN" >/dev/null

# 성공까지 대기 (실패 메시지 나오면 즉시 중단)
for A in "$SRC_ARN" "$TGT_ARN"; do
  echo "▶ waiting connection to be successful: $A"
  while true; do
    STATUS=$(aws dms describe-connections \
      --filters Name=endpoint-arn,Values=$A \
      --query 'Connections[0].Status' --output text)
    FAIL=$(aws dms describe-connections \
      --filters Name=endpoint-arn,Values=$A \
      --query 'Connections[0].LastFailureMessage' --output text)
    echo "   status=$STATUS"
    if [ "$STATUS" = "successful" ]; then break; fi
    if [ "$STATUS" = "failed" ] || [ "$FAIL" != "None" ] && [ "$FAIL" != "null" ]; then
      echo "❌ connection failed: $FAIL"
      exit 1
    fi
    sleep 3
  done
done

# 태스크 시작 (전체 로드)
echo "▶ starting replication task..."
aws dms start-replication-task \
  --replication-task-arn "$TASK_ARN" \
  --start-replication-task-type start-replication

# 상태/진척 모니터링 루프 (원하면 Ctrl+C로 빠져나와도 됨)
echo "▶ monitoring..."
while true; do
  aws dms describe-replication-tasks \
    --filters Name=replication-task-arn,Values="$TASK_ARN" \
    --query 'ReplicationTasks[0].[Status,StopReason,LastFailureMessage,ReplicationTaskStats]' \
    --output table
  aws dms describe-table-statistics \
    --replication-task-arn "$TASK_ARN" \
    --query 'TableStatistics[].[SchemaName,TableName,FullLoadProgressPercent,Inserts,Updates,Deletes]' \
    --output table
  sleep 10
done
