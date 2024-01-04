#! /bin/bash
sudo yum install -y git libicu
curl --retry-all-errors --retry 5 -L https://github.com/defenseunicorns/uds-cli/releases/download/v0.4.1/uds-cli_v0.4.1_Linux_amd64 -o uds
chmod +x uds
sudo mv uds /usr/local/bin/
curl --retry-all-errors --retry 5 -L https://github.com/defenseunicorns/zarf/releases/download/v0.31.4/zarf_v0.31.4_Linux_amd64 -o zarf
chmod +x zarf
sudo mv zarf /usr/local/bin
cd ~ && mkdir actions-runner && cd actions-runner
curl --retry-all-errors --retry 5 -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz -o actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
# Manual config of runner for now
