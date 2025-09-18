# ECS Execution Role
resource "aws_iam_role" "ecs_execution" {
  name = "${var.resource_prefix}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role
resource "aws_iam_role" "ecs_task" {
  name = "${var.resource_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach ECR read-only policy for ECS task role
resource "aws_iam_role_policy_attachment" "ecs_task_ecr" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Lambda execution role
resource "aws_iam_role" "lambda_execution" {
  name = "${var.resource_prefix}-lambda-execution-role"

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

  tags = local.common_tags
}

# Attach AWS managed policies for Lambda execution
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# S3 access policy for Lambda execution role
resource "aws_iam_role_policy" "lambda_s3" {
  name = "AllowLambdaAccessToBuckets"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          for k,bucket in aws_s3_bucket.buckets : "${bucket.arn}/*" if local.buckets[k].public
        ]
      }
    ]
  })
}

# Lambda proxy policy for ECS task role (to invoke Lambda functions)
resource "aws_iam_role_policy" "ecs_lambda_proxy" {
  name = "LambdaProxyPolicy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "arn:aws:lambda:*:*:function:ownstak-*"
      }
    ]
  })
}

# CI IAM User
resource "aws_iam_user" "ci" {
  name = "${var.resource_prefix}-ci-user"
  path = "/"

  tags = local.common_tags
}

# CI IAM Policy for Lambda operations
resource "aws_iam_policy" "ci_lambda" {
  name        = "${var.resource_prefix}-ci-lambda-policy"
  description = "Policy for CI user to manage Lambda functions and aliases"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:ListFunctions",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:CreateAlias",
          "lambda:DeleteAlias",
          "lambda:GetAlias",
          "lambda:ListAliases",
          "lambda:UpdateAlias",
          "lambda:InvokeFunction",
          "lambda:ListVersionsByFunction",
          "lambda:PublishVersion",
        ]
        Resource = [
          "arn:aws:lambda:*:*:function:${var.resource_prefix}-*",
          "arn:aws:lambda:*:*:function:${var.resource_prefix}-*:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = aws_iam_role.lambda_execution.arn
      }
    ]
  })

  tags = local.common_tags
}

# CI IAM Policy for S3 operations
resource "aws_iam_policy" "ci_s3" {
  name        = "${var.resource_prefix}-ci-s3-policy"
  description = "Policy for CI user to manage S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = concat(
          [for bucket in aws_s3_bucket.buckets : bucket.arn],
          [for bucket in aws_s3_bucket.buckets : "${bucket.arn}/*"]
        )
      }
    ]
  })

  tags = local.common_tags
}

# Attach Lambda policy to CI user
resource "aws_iam_user_policy_attachment" "ci_lambda" {
  user       = aws_iam_user.ci.name
  policy_arn = aws_iam_policy.ci_lambda.arn
}

# Attach S3 policy to CI user
resource "aws_iam_user_policy_attachment" "ci_s3" {
  user       = aws_iam_user.ci.name
  policy_arn = aws_iam_policy.ci_s3.arn
}

# Create access keys for CI user
resource "aws_iam_access_key" "ci" {
  user = aws_iam_user.ci.name
}

