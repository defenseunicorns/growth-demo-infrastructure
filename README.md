###########################

!!! This is a work in progress and has not yet been fully implemented for Growth Demos.

###########################

# Growth Demo Infrastructure

This repository houses the infrastructure that is currently destined to the `uds.wtf` domain.

## Managing Bundles

Individual teams will manage their bundles under the `bundles/` directory of the repository. This directory contains sub-folders that correspond to each team's bundle and those contain the `uds-bundle.yaml` and `uds-config.yaml` that team has configured for `uds.wtf`.

> :warning: **Note:** Some teams may need/want to generate their `uds-config.yaml` from Terraform similar to [`terraform/swf/uds-config.tf`](terraform/swf/uds-config.tf).  You may also need to coordinate with members of the `@defenseunicorns/uds-staging` group to have dependencies setup within the environment.

### Updating Bundles

Bundles are updated by corresponding team-members through a PR opened to the repository. This PR must be approved **_both_** by another member of that same team **_and_** by a member of the `@defenseunicorns/uds-staging` group.  Once approved, it can be merged to `main` and is ready for promotion.

### Promoting Bundles

Currently both `prod` (not fully setup) and `staging` track off of `main`, but the individual bundles deployed into an environment are based on GitHub workflow inputs.  This allows individual bundles to be updated without affecting the others.  Teams wanting their bundles in environment should reach out to members of the `@defenseunicorns/uds-staging` group to kickoff the applicable workflow(s) to promote their bundle.

## Environment Setup

### `bootstrap`

`cd` to `terraform/bootstrap` to bootstrap a new environment with state and GitHub resources.

> :warning: **Note:** `@justin-o12` needs to write detailed instructions, but you will need to do some of this manually in order to get the state in region.  For now manually sync with him if you are spinning up an entirely new environment.

### `platform`

`cd` to `terraform/platform` to deploy the platform including VPC and the RKE2 cluster.  GitHub Actions workflows will add the required variables for testing (`test-*`) and deploying (`deploy-*`).  You can provide your own `tfvars` file for local testing.

Some variables to note:

- Set `public_access` to `true` to use public subnets and an external controlplane load balancer.  `false` will do the opposite.
- Set `create_bastion` to `true` to create a bastion in a private subnet to access the cluster.  Follow [Amazon's Bastion Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/access-a-bastion-host-by-using-session-manager-and-amazon-ec2-instance-connect.html) to connect through SSM.
- Set `enable_ssh` to `true` to allow SSH access to cluster nodes.  This will create a local SSH key you can use to SSH into the nodes.  If the cluster is private, you will need to go through the bastion.
