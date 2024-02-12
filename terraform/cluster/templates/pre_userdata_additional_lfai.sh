# this is only supported on a rhel based AMI/node
sudo dnf install kernel-devel-$(uname -r) kernel-headers-$(uname -r) -y
sudo rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
sudo yum-config-manager --enable rhel-8-appstream-rhui-rpms
sudo yum-config-manager --enable rhel-8-baseos-rhui-rpms
sudo yum-config-manager --enable codeready-builder-for-rhel-8-rhui-rpms
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
sudo dnf clean expire-cache
sudo dnf module install nvidia-driver:latest-dkms -y
sudo dnf install cuda-toolkit -y
sudo dnf install nvidia-gds -y
sudo cd /sbin && sudo ln -s ldconfig ldconfig.real
