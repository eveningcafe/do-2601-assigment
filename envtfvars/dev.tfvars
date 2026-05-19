vpc_cidr_block     = "10.0.0.0/16"
eks_name           = "do2504-eks-08"
node_group_name    = "do2504-nodegr-08"
vpc_name           = "do2504-hieptvh-vpc"
my_aws_console_key = "hieptvh-key-aws-vti"

ec2instances = {
  "do2504-vm1-08" = {
    ec2InstanceName           = "do2504-vm1-08"
    ec2ami                    = "ami-01dc51e87421923b6" // amazon linux
    ec2InstanceType           = "t2.micro"
    trusted_ip_ranges         = ["113.190.246.14/32"]
    public_key                = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICs90EoRM8hNt104FHGBor75TwIxH0YluFRXiEtBwSoR hr@DESKTOP-UR0DT47" // ssh key-gen from local machine
    assiate_public_ip_address = false
  },
  "do2504-vm2-08" = {
    ec2InstanceName           = "do2504-vm2-08"
    ec2ami                    = "ami-01dc51e87421923b6" // amazon linux
    ec2InstanceType           = "t2.small"
    trusted_ip_ranges         = ["113.190.246.14/32"]
    public_key                = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICs90EoRM8hNt104FHGBor75TwIxH0YluFRXiEtBwSoR hr@DESKTOP-UR0DT47"
    assiate_public_ip_address = true
  },
  "do2504-jenkins-08" = {
    ec2InstanceName           = "do2504-jenkins-08"
    ec2ami                    = "ami-01dc51e87421923b6" // amazon linux
    ec2InstanceType           = "t2.medium"
    trusted_ip_ranges         = ["0.0.0.0/0"] // Allow from internet for HTTP/HTTPS/Jenkins
    public_key                = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICs90EoRM8hNt104FHGBor75TwIxH0YluFRXiEtBwSoR hr@DESKTOP-UR0DT47"
    assiate_public_ip_address = true
    ingress_rules = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        description = "SSH access"
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        description = "HTTP access"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        description = "HTTPS access"
      },
      {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        description = "Jenkins web interface"
      }
    ]
    user_data = <<-EOF
            #!/bin/bash
            set -e
            
            # Update system
            yum update -y
            
            # Install Java 17 (required for Jenkins)
            yum install -y java-17-amazon-corretto-devel
            
            # Add Jenkins repository
            wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
            rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
            
            # Install Jenkins
            yum install -y jenkins
            
            # Start and enable Jenkins
            systemctl start jenkins
            systemctl enable jenkins
            
            # Wait for Jenkins to start
            sleep 30
            
            # Get initial admin password and save to a file readable by ec2-user
            if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
                cp /var/lib/jenkins/secrets/initialAdminPassword /home/ec2-user/jenkins-initial-password.txt
                chown ec2-user:ec2-user /home/ec2-user/jenkins-initial-password.txt
                chmod 644 /home/ec2-user/jenkins-initial-password.txt
            fi
            
            # Create a completion marker
            echo "Jenkins installation completed at $(date)" > /home/ec2-user/jenkins-install-complete.txt
            chown ec2-user:ec2-user /home/ec2-user/jenkins-install-complete.txt
        EOF
  }
}