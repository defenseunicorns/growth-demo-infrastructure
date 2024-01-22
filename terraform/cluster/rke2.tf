data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "oidc_bucket" {
  bucket = "${var.environment}-oidc"
}

locals {
  # NOTE: This needs to match the cluster name in ../irsa/iam.tf
  cluster_name = "uds-${var.environment}"

  pre_userdata = <<-EOF
echo "Adding AWS cloud provider manifest."
mkdir -p /var/lib/rancher/rke2/server/manifests

cat > /var/lib/rancher/rke2/server/manifests/00-aws-ccm.yaml << EOM
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: aws-cloud-controller-manager
  namespace: kube-system
spec:
  chart: aws-cloud-controller-manager
  repo: https://kubernetes.github.io/cloud-provider-aws
  version: 0.0.8
  targetNamespace: kube-system
  bootstrap: true
  valuesContent: |-
    nodeSelector:
      node-role.kubernetes.io/control-plane: "true"
    hostNetworking: true
    args:
      - --configure-cloud-routes=false
      - --v=2
      - --cloud-provider=aws
EOM

cat > /var/lib/rancher/rke2/server/manifests/01-aws-ebs.yaml << EOM
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: aws-ebs-csi-driver
  namespace: kube-system
spec:
  chart: aws-ebs-csi-driver
  repo: https://kubernetes-sigs.github.io/aws-ebs-csi-driver
  version: 2.25.0
  targetNamespace: kube-system
  valuesContent: |-
    storageClasses:
      - name: default
        annotations:
          storageclass.kubernetes.io/is-default-class: "true"
        allowVolumeExpansion: true
        provisioner: kubernetes.io/aws-ebs
        volumeBindingMode: WaitForFirstConsumer
        parameters:
          type: gp3
        reclaimPolicy: Retain
EOM

echo "Installing awscli"
yum install -y unzip jq
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "Getting OIDC keypair"
sudo mkdir /irsa
sudo chown ec2-user:ec2-user /irsa
aws secretsmanager get-secret-value --secret-id ${var.environment}-oidc-private-key | jq -r '.SecretString' > /irsa/signer.key
aws secretsmanager get-secret-value --secret-id ${var.environment}-oidc-public-key | jq -r '.SecretString' > /irsa/signer.key.pub
chcon -t svirt_sandbox_file_t /irsa/*

# This is done via yq because the RKE2 module input doesn't merge with existing config
echo "Setting up RKE2 config file"
curl -L https://github.com/mikefarah/yq/releases/download/v4.40.4/yq_linux_amd64 -o yq
chmod +x yq
./yq -i '.kube-apiserver-arg += "service-account-key-file=/irsa/signer.key.pub"' /etc/rancher/rke2/config.yaml
./yq -i '.kube-apiserver-arg += "service-account-signing-key-file=/irsa/signer.key"' /etc/rancher/rke2/config.yaml
./yq -i '.kube-apiserver-arg += "api-audiences=kubernetes.svc.default"' /etc/rancher/rke2/config.yaml
./yq -i '.kube-apiserver-arg += "service-account-issuer=https://${data.aws_s3_bucket.oidc_bucket.bucket_regional_domain_name}"' /etc/rancher/rke2/config.yaml
rm -rf ./yq
EOF

  post_userdata = <<-EOF
# This needs to match https://github.com/defenseunicorns/uds-rke2-image-builder/blob/main/packer/scripts/rke2-startup.sh#L53
echo "Fixing RKE2 file permissions for STIG"
dir=/etc/rancher/rke2
chmod -R 0600 $dir/*
chown -R root:root $dir/*

dir=/var/lib/rancher/rke2
chown root:root $dir/*

dir=/var/lib/rancher/rke2/agent
chown root:root $dir/*
chmod 0700 $dir/pod-manifests
chmod 0700 $dir/etc
find $dir -maxdepth 1 -type f -name "*.kubeconfig" -exec chmod 0640 {} \;
find $dir -maxdepth 1 -type f -name "*.crt" -exec chmod 0600 {} \;
find $dir -maxdepth 1 -type f -name "*.key" -exec chmod 0600 {} \;

dir=/var/lib/rancher/rke2/bin
chown root:root $dir/*
chmod 0750 $dir/*

dir=/var/lib/rancher/rke2/data
chown root:root $dir
chmod 0750 $dir
chown root:root $dir/*
chmod 0640 $dir/*

dir=/var/lib/rancher/rke2/server
chown root:root $dir/*
chmod 0700 $dir/cred
chmod 0700 $dir/db
chmod 0700 $dir/tls
chmod 0751 $dir/manifests
chmod 0750 $dir/logs
chmod 0600 $dir/token
EOF
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["uds-${var.environment}"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

module "rke2" {
  source = "github.com/rancherfederal/rke2-aws-tf?ref=v2.4.0"

  cluster_name         = local.cluster_name
  unique_suffix        = false
  vpc_id               = data.aws_vpc.vpc.id
  subnets              = var.public_access ? data.aws_subnets.public_subnets.ids : data.aws_subnets.private_subnets.ids
  iam_instance_profile = "${var.environment}-rke2-server"

  #
  # Server pool config
  #
  instance_type            = var.server_instance_type
  ami                      = var.rke2_ami
  iam_permissions_boundary = var.permissions_boundary
  block_device_mappings = {
    size      = var.server_block_device_size
    encrypted = true
    type      = "gp3"
  }
  servers                     = var.num_rke2_servers
  extra_block_device_mappings = var.server_extra_block_device_mappings

  #
  # Controlplane Config
  #
  controlplane_internal = var.public_access ? false : true

  #
  # RKE2 Config
  #
  download                  = false
  pre_userdata              = local.pre_userdata
  post_userdata             = local.post_userdata
  enable_ccm                = true
  ccm_external              = true
  wait_for_capacity_timeout = "30m"

  ssh_authorized_keys         = var.enable_ssh ? [tls_private_key.ssh[0].public_key_openssh] : []
  associate_public_ip_address = var.public_access ? true : false
}

module "rke2_agents" {
  source = "github.com/rancherfederal/rke2-aws-tf//modules/agent-nodepool?ref=v2.4.0"

  name          = "agent"
  vpc_id        = data.aws_vpc.vpc.id
  subnets       = var.public_access ? data.aws_subnets.public_subnets.ids : data.aws_subnets.private_subnets.ids
  ami           = var.rke2_ami
  instance_type = var.agent_instance_type

  #
  # Nodepool Config
  #
  iam_permissions_boundary = var.permissions_boundary
  block_device_mappings = {
    size      = var.agent_block_device_size
    encrypted = true
    type      = "gp3"
  }
  asg = {
    min : var.agent_asg_min,
    max : var.agent_asg_max,
    desired : var.agent_asg_desired,
    termination_policies : ["Default"]
  }
  extra_block_device_mappings = var.agent_extra_block_device_mappings

  #
  # RKE2 Config
  #
  cluster_data              = module.rke2.cluster_data
  enable_ccm                = true
  ccm_external              = true
  download                  = false
  pre_userdata              = local.pre_userdata
  post_userdata             = local.post_userdata
  wait_for_capacity_timeout = "30m"

  ssh_authorized_keys = var.enable_ssh ? [tls_private_key.ssh[0].public_key_openssh] : []
}

#
# SSH Config for Testing
#
resource "tls_private_key" "ssh" {
  count = var.enable_ssh ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_pem" {
  count = var.enable_ssh ? 1 : 0

  filename        = "${local.cluster_name}.pem"
  content         = tls_private_key.ssh[0].private_key_pem
  file_permission = "0600"
}

resource "aws_security_group_rule" "quickstart_ssh" {
  count = var.enable_ssh ? 1 : 0

  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.rke2.cluster_data.cluster_sg
  type              = "ingress"
  cidr_blocks       = var.public_access ? ["0.0.0.0/0"] : [data.aws_vpc.vpc.cidr_block]
}

#
# AWS Load Balancer Controller
#
resource "aws_iam_policy" "aws_lb_controller_policy" {
  name = "${var.environment}-aws-lb-controller-policy"
  policy = templatefile("templates/aws_lb_controller_policy.json", {
    vpc_arn       = data.aws_vpc.vpc.arn
    arn_partition = data.aws_partition.current.partition
  })
}

resource "aws_iam_role" "aws_lb_controller_role" {
  name = "${var.environment}-aws-lb-controller-role"
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
            "${data.aws_s3_bucket.oidc_bucket.bucket_regional_domain_name}:sub" : "system:serviceaccount:kube-system:aws-lb-controller"
          }
        }
      }
    ]
  })

  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller_iam_attachment" {
  role       = aws_iam_role.aws_lb_controller_role.name
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
}