#! /bin/bash
sudo yum install -y git libicu
cd ~ && mkdir actions-runner && cd actions-runner
curl --retry-all-errors --retry 5 -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz -o actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
# Manual config of runner for now
