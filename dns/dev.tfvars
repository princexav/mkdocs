environment   = "dev"
team_name     = "team-excellence"

# ─── YOUR DOMAIN ───
# Replace with your actual registered domain
domain_name = "team-healthpulse.com"

# ─── YOUR INFRASTRUCTURE IPs ───
# Get these from your other Terraform outputs:
#   cd ../baremetal && terraform output public_ip
#   cd ../k3s && terraform output master_public_ip
baremetal_ip  = "REPLACE_WITH_BAREMETAL_EIP"
k3s_master_ip = "REPLACE_WITH_K3S_MASTER_EIP"
