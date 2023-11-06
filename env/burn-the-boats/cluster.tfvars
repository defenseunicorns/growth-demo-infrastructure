// Variables for the Burn the Boats cluster (RKE2)
rke2_ami = "ami-00249779f19dcc1a5"
num_rke2_servers = 3
agent_asg_min = 1
agent_asg_max = 1
agent_asg_desired = 1
server_instance_type = "t3.medium"
agent_instance_type = "m5.2xlarge"
enable_ssh = true
server_extra_block_device_mappings = [
    {
      device_name = "/dev/sdb"
      size        = 100
      encrypted   = true
      type        = "gp3"
    }
  ]
agent_extra_block_device_mappings = [
    {
      device_name = "/dev/sdb"
      size        = 100
      encrypted   = true
      type        = "gp3"
    }
  ]