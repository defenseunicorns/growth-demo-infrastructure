//
// IAM to support RKE2 server nodes
//
locals {
  # NOTE: This needs to match the cluster name in ../cluster/rke2.tf
  cluster_name = "uds-${var.environment}"
}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "ec2_access" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "rke2_server" {
  name = "${local.cluster_name}-server"

  assume_role_policy   = data.aws_iam_policy_document.ec2_access.json
  permissions_boundary = var.permissions_boundary

  tags = {
    PermissionsBoundary = split("/", var.permissions_boundary)[1]
  }
}

resource "aws_iam_instance_profile" "rke2_server" {
  name = "${var.environment}-rke2-server"
  role = aws_iam_role.rke2_server.name
}

// Permissions to get token from S3
data "aws_iam_policy_document" "s3_token" {
  statement {
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${local.cluster_name}-*"]
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
  }
}

// Permissions to get OIDC keys from secrets manager
data "aws_iam_policy_document" "oidc_secrets" {
  statement {
    effect = "Allow"
    resources = [
      aws_secretsmanager_secret.public_key.arn,
      aws_secretsmanager_secret.private_key.arn,
    ]
    actions = [
      "secretsmanager:GetSecretValue"
    ]
  }
}

// Cloud controller permissions from upstream - https://github.com/rancherfederal/rke2-aws-tf/blob/d65cb1d0543264f3170d077a2a0527fd95bfd1ae/data.tf#L80
data "aws_iam_policy_document" "aws_ccm" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:DescribeAutoScalingInstances",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyVolume",
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteVolume",
      "ec2:DetachVolume",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DescribeVpcs",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:AttachLoadBalancerToSubnets",
      "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancerPolicy",
      "elasticloadbalancing:CreateLoadBalancerListeners",
      "elasticloadbalancing:ConfigureHealthCheck",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancerListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DetachLoadBalancerFromSubnets",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerPolicies",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
      "iam:CreateServiceLinkedRole",
      "kms:DescribeKey"
    ]
  }
}

resource "aws_iam_role_policy" "s3_token" {
  name   = "${var.environment}-rke2-server-token"
  role   = aws_iam_role.rke2_server.id
  policy = data.aws_iam_policy_document.s3_token.json
}


resource "aws_iam_role_policy" "oidc_secrets" {
  name   = "${var.environment}-rke2-server-oidc"
  role   = aws_iam_role.rke2_server.id
  policy = data.aws_iam_policy_document.oidc_secrets.json
}

resource "aws_iam_role_policy" "server_ccm" {
  name   = "${var.environment}-rke2-server-ccm"
  role   = aws_iam_role.rke2_server.id
  policy = data.aws_iam_policy_document.aws_ccm.json
}
