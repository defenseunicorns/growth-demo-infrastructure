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
