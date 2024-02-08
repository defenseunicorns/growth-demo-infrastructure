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
yum install -y unzip jq || apt-get -y install unzip jq
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
