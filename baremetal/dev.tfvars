environment        = "dev"
team_name          = "team-excellence"
instance_type      = "t2.micro"
volume_size        = 10
vpc_cidr           = "10.10.0.0/16"
public_subnet_cidr = "10.10.1.0/24"
ssh_allowed_cidr   = "0.0.0.0/0"   # CHANGE THIS — restrict to your IP (e.g. "41.58.x.x/32")
