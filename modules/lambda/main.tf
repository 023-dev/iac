# IAM Role for convert-mp4-to-hls Lambda
resource "aws_iam_role" "convert_mp4_to_hls_role" {
  name = "convert-mp4-to-hls-role-v90p5sxo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "convert-mp4-to-hls-role"
  }
}

# IAM Policy for convert-mp4-to-hls Lambda
resource "aws_iam_role_policy" "convert_mp4_to_hls_policy" {
  name = "convert-mp4-to-hls-policy"
  role = aws_iam_role.convert_mp4_to_hls_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${var.s3_bucket_arns.unretired_dev_mp4}/*",
          "${var.s3_bucket_arns.unretired_dev_abs}/*",
          "${var.s3_bucket_arns.unretired_prod_abs}/*",
          "${var.s3_bucket_arns.unretired_dev_origin}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arns.unretired_dev_mp4,
          var.s3_bucket_arns.unretired_dev_abs,
          var.s3_bucket_arns.unretired_prod_abs,
          var.s3_bucket_arns.unretired_dev_origin
        ]
      }
    ]
  })
}

# CloudWatch Log Group for convert-mp4-to-hls
resource "aws_cloudwatch_log_group" "convert_mp4_to_hls" {
  name              = "/aws/lambda/convert-mp4-to-hls"
  retention_in_days = 14

  tags = {
    Name = "convert-mp4-to-hls-logs"
  }
}

# Lambda Function: convert-mp4-to-hls
resource "aws_lambda_function" "convert_mp4_to_hls" {
  function_name = "convert-mp4-to-hls"
  role          = aws_iam_role.convert_mp4_to_hls_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"
  timeout       = 3
  memory_size   = 128

  # Placeholder code - 실제 코드는 별도로 업로드 필요
  filename         = "${path.module}/lambda_code/convert-mp4-to-hls.zip"
  source_code_hash = data.archive_file.convert_mp4_to_hls_zip.output_base64sha256

  environment {
    variables = {
      S3_BUCKET_DEV_MP4    = var.s3_bucket_names.unretired_dev_mp4
      S3_BUCKET_DEV_ABS    = var.s3_bucket_names.unretired_dev_abs
      S3_BUCKET_PROD_ABS   = var.s3_bucket_names.unretired_prod_abs
      S3_BUCKET_DEV_ORIGIN = var.s3_bucket_names.unretired_dev_origin
    }
  }

  depends_on = [
    aws_iam_role_policy.convert_mp4_to_hls_policy,
    aws_cloudwatch_log_group.convert_mp4_to_hls
  ]

  tags = {
    Name = "convert-mp4-to-hls"
  }
}

# IAM Role for AWS QuickSetup Lifecycle Lambda
resource "aws_iam_role" "quicksetup_lifecycle_role" {
  name = "AWS-QuickSetup-SSM-LifecycleManagement-LA-ap-northeast-2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  tags = {
    Name = "quicksetup-lifecycle-role"
  }
}

# CloudWatch Log Group for QuickSetup Lifecycle
resource "aws_cloudwatch_log_group" "quicksetup_lifecycle" {
  name              = "/aws/lambda/aws-quicksetup-lifecycle-LA-cptq3"
  retention_in_days = 14

  tags = {
    Name = "quicksetup-lifecycle-logs"
  }
}

# Lambda Function: AWS QuickSetup Lifecycle
resource "aws_lambda_function" "quicksetup_lifecycle" {
  function_name = "aws-quicksetup-lifecycle-LA-cptq3"
  role          = aws_iam_role.quicksetup_lifecycle_role.arn
  handler       = "index.reconcile"
  runtime       = "python3.11"
  timeout       = 900
  memory_size   = 128

  # Placeholder code - AWS 관리 함수이므로 실제 코드는 AWS에서 관리
  filename         = "${path.module}/lambda_code/quicksetup-lifecycle.zip"
  source_code_hash = data.archive_file.quicksetup_lifecycle_zip.output_base64sha256

  environment {
    variables = {
      REGION = var.aws_region
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.quicksetup_lifecycle
  ]

  tags = {
    Name = "quicksetup-lifecycle"
  }
}

# Archive files for Lambda deployment packages
data "archive_file" "convert_mp4_to_hls_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_code/convert-mp4-to-hls.zip"
  source {
    content = templatefile("${path.module}/lambda_code/convert_mp4_to_hls.py", {
      # Template variables if needed
    })
    filename = "lambda_function.py"
  }
}

data "archive_file" "quicksetup_lifecycle_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_code/quicksetup-lifecycle.zip"
  source {
    content = templatefile("${path.module}/lambda_code/quicksetup_lifecycle.py", {
      # Template variables if needed
    })
    filename = "index.py"
  }
}
