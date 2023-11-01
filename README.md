# uds-prod-infrastructure
## bootstrap
`cd` to `terraform/bootstrap` to bootstrap a new environment with state and GitHub resources.  I need to write detailed
instructions, but you will need to do some of this manually in order to get the state in region.

## platform
`cd` to `terraform/platform` to deploy the platform including VPC and the RKE2 cluster.  GitHub Actions workflows will
add the required variables for testing and deploying.  You can provide your own `tfvars` file for local testing.

Some variables to note:
- Set `public_access` to `true` to use public subnets and external controlplane load balancer.  `false` will do the opposite.
- Set `create_bastion` to `true` to create a bastion in a private subnet to access the cluster.  Follow [this](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/access-a-bastion-host-by-using-session-manager-and-amazon-ec2-instance-connect.html) to connect through SSM.
- Set `enable_ssh` to `true` to allow SSH access to cluster nodes.  This will create a local SSH key you can use to SSH into the nodes.  If the cluster is private, you will need to go through the bastion.
