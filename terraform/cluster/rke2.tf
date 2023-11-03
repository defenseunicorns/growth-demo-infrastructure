locals {
  cluster_name = "uds-${var.environment}-cluster"

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

echo "Installing awscli"
yum install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
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

echo "Fixing SELinux file context so local path provisioner can work."
mkdir -p /opt/local-path-provisioner
semanage fcontext -a -t container_file_t "/opt/local-path-provisioner(/.*)?"
restorecon -R /opt/local-path-provisioner

echo "Adding local path storage manifest."
cat > /var/lib/rancher/rke2/server/manifests/10-local-path-storage.yaml << EOM
apiVersion: v1
kind: Namespace
metadata:
  name: local-path-storage
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: local-path-provisioner-service-account
  namespace: local-path-storage
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: local-path-provisioner-role
rules:
  - apiGroups: [ "" ]
    resources: [ "nodes", "persistentvolumeclaims", "configmaps" ]
    verbs: [ "get", "list", "watch" ]
  - apiGroups: [ "" ]
    resources: [ "endpoints", "persistentvolumes", "pods" ]
    verbs: [ "*" ]
  - apiGroups: [ "" ]
    resources: [ "events" ]
    verbs: [ "create", "patch" ]
  - apiGroups: [ "storage.k8s.io" ]
    resources: [ "storageclasses" ]
    verbs: [ "get", "list", "watch" ]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: local-path-provisioner-bind
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: local-path-provisioner-role
subjects:
  - kind: ServiceAccount
    name: local-path-provisioner-service-account
    namespace: local-path-storage
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: local-path-provisioner
  namespace: local-path-storage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: local-path-provisioner
  template:
    metadata:
      labels:
        app: local-path-provisioner
    spec:
      serviceAccountName: local-path-provisioner-service-account
      containers:
        - name: local-path-provisioner
          image: rancher/local-path-provisioner:v0.0.24
          imagePullPolicy: IfNotPresent
          command:
            - local-path-provisioner
            - --debug
            - start
            - --config
            - /etc/config/config.json
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config/
          env:
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
      volumes:
        - name: config-volume
          configMap:
            name: local-path-config
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
  annotations:
    storageclass.kubernetes.io/is-default-class: 'true'
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: local-path-config
  namespace: local-path-storage
data:
  config.json: |-
    {
      "nodePathMap":[
        {
          "node":"DEFAULT_PATH_FOR_NON_LISTED_NODES",
          "paths":["/opt/local-path-provisioner"]
        }
      ]
    }
  setup: |-
    #!/bin/sh
    set -eu
    mkdir -m 0777 -p "\$VOL_DIR"
  teardown: |-
    #!/bin/sh
    set -eu
    rm -rf "\$VOL_DIR"
  helperPod.yaml: |-
    apiVersion: v1
    kind: Pod
    metadata:
      name: helper-pod
    spec:
      containers:
      - name: helper-pod
        image: busybox
        imagePullPolicy: IfNotPresent
EOM
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

  cluster_name  = local.cluster_name
  unique_suffix = false
  vpc_id        = data.aws_vpc.vpc.id
  subnets       = var.public_access ? data.aws_subnets.public_subnets : data.aws_subnets.private_subnets

  #
  # Server pool config
  #
  instance_type            = var.server_instance_type
  ami                      = var.rke2_ami
  iam_permissions_boundary = var.permissions_boundary
  block_device_mappings = {
    size      = 100
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
  subnets       = var.public_access ? data.aws_subnets.public_subnets : data.aws_subnets.private_subnets
  ami           = var.rke2_ami
  instance_type = var.agent_instance_type

  #
  # Nodepool Config
  #
  iam_permissions_boundary = var.permissions_boundary
  block_device_mappings = {
    size      = 100
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
  cidr_blocks       = var.public_access ? ["0.0.0.0/0"] : [for s in data.aws_subnets.private_subnets : s.cidr_blocks]
}
