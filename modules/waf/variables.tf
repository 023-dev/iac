variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (source/target)"
  type        = string
}

variable "alb_arn" {
  description = "ALB ARN to associate with WAF (optional)"
  type        = string
  default     = ""
}

variable "rate_limit" {
  description = "Rate limit for requests per 5 minutes"
  type        = number
  default     = 2000
}

variable "blocked_countries" {
  description = "List of country codes to block"
  type        = list(string)
  default     = []
}
