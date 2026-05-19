vpc_name = "vpc-prod"

ec2instances = {
  "vm1" = {
    ec2InstanceName           = "vm1-prod"
    ec2ami                    = "ami-06571d6ae17e327ff" // amazon linux
    ec2InstanceType           = "t2.small"
    trusted_ip_ranges         = ["113.190.246.2/32"]
    public_key                = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICs90EoRM8hNt104FHGBor75TwIxH0YluFRXiEtBwSoR hr@DESKTOP-UR0DT47" // ssh key-gen from local machine
    assiate_public_ip_address = false
  },
  "vm2" = {
    ec2InstanceName           = "vm2-prod"
    ec2ami                    = "ami-06571d6ae17e327ff" // amazon linux
    ec2InstanceType           = "t2.medium"
    trusted_ip_ranges         = ["113.190.246.2/32"]
    public_key                = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICs90EoRM8hNt104FHGBor75TwIxH0YluFRXiEtBwSoR hr@DESKTOP-UR0DT47"
    assiate_public_ip_address = true
  }
}