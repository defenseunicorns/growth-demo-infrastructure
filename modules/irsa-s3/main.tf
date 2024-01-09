data "aws_s3_bucket" "oidc_bucket" {
  bucket = "${var.environment}-oidc"
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

## This will create a policy for the S3 Buckets
resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "${var.resource_prefix}policy"
  path        = "/"
  description = "IRSA policy to access GitLab buckets."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = [
          for bucket_name in var.bucket_names :
          "arn:${data.aws_partition.current.partition}:s3:::uds-${bucket_name}-${var.environment}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          for bucket_name in var.bucket_names :
          "arn:${data.aws_partition.current.partition}:s3:::uds-${bucket_name}-${var.environment}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = [var.kms_key_arn]
      }
    ]
  })
}

## Create service account role
resource "aws_iam_role" "s3_bucket_role" {
  for_each = toset(var.serviceaccount_names)

  name = "${var.resource_prefix}${each.value}-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
          "Federated" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${data.aws_s3_bucket.oidc_bucket.bucket_regional_domain_name}"
        }
        "Condition" : {
          "StringEquals" : {
            "${data.aws_s3_bucket.oidc_bucket.bucket_regional_domain_name}:aud" : "irsa",
            "${data.aws_s3_bucket.oidc_bucket.bucket_regional_domain_name}:sub" : "system:serviceaccount:gitlab:${each.value}"
          }
        }
      }
    ]
  })

  permissions_boundary = var.permissions_boundary

  tags = {
    PermissionsBoundary = split("/", var.permissions_boundary)[1]
  }
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  for_each = toset(var.serviceaccount_names)

  role       = "${var.resource_prefix}${each.value}-s3-role"
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
}
