// Variables for the Burn the Boats cluster (RKE2)
rke2_ami                 = "ami-00249779f19dcc1a5"
num_rke2_servers         = 3
agent_asg_min            = 1
agent_asg_max            = 3
agent_asg_desired        = 1
server_instance_type     = "m5.2xlarge"
agent_instance_type      = "m5.4xlarge"
enable_ssh               = true
server_block_device_size = 150
agent_block_device_size  = 150
enable_lfai_agents       = true
lfai_rke2_ami            = "ami-00249779f19dcc1a5"
