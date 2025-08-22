output "convert_mp4_to_hls_function_name" {
  description = "Convert MP4 to HLS Lambda function name"
  value       = aws_lambda_function.convert_mp4_to_hls.function_name
}

output "convert_mp4_to_hls_function_arn" {
  description = "Convert MP4 to HLS Lambda function ARN"
  value       = aws_lambda_function.convert_mp4_to_hls.arn
}

output "convert_mp4_to_hls_role_arn" {
  description = "Convert MP4 to HLS Lambda role ARN"
  value       = aws_iam_role.convert_mp4_to_hls_role.arn
}

output "quicksetup_lifecycle_function_name" {
  description = "QuickSetup Lifecycle Lambda function name"
  value       = aws_lambda_function.quicksetup_lifecycle.function_name
}

output "quicksetup_lifecycle_function_arn" {
  description = "QuickSetup Lifecycle Lambda function ARN"
  value       = aws_lambda_function.quicksetup_lifecycle.arn
}

output "quicksetup_lifecycle_role_arn" {
  description = "QuickSetup Lifecycle Lambda role ARN"
  value       = aws_iam_role.quicksetup_lifecycle_role.arn
}
