// passing variables to the module
// from main.tf to _modules/vpc/variables.tf
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "DO0000091-hieptvh-vpc"
}

variable "vpc_cidr_block" {
  description = "The cidr block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "my_aws_console_key" {
  description = "The name of the key pair to use"
  type        = string
  default     = "hiep-do2601"
}

variable "ec2instances" {
  description = "Map of EC2 instances to create"
  type = map(object({
    ec2InstanceName           = string
    ec2ami                    = string
    ec2InstanceType           = string
    trusted_ip_ranges         = list(string)
    public_key                = string
    assiate_public_ip_address = bool
    ingress_rules             = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      description = string
    })))
    user_data                 = optional(string)
  }))
  default = {
    # "do2504-vm1-08" = {
    #   ec2InstanceName           = "do2504-vm1-08"
    #   ec2ami                    = "ami-01dc51e87421923b6"
    #   ec2InstanceType           = "t2.micro"
    #   trusted_ip_ranges         = ["113.190.246.14/32"]
    #   public_key                = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICs90EoRM8hNt104FHGBor75TwIxH0YluFRXiEtBwSoR hr@DESKTOP-UR0DT47"
    #   assiate_public_ip_address = false
    # }
    # "do2504-vm2-08" = {
    #   ec2InstanceName           = "do2504-vm2-08"
    #   ec2ami                    = "ami-01dc51e87421923b6"
    #   ec2InstanceType           = "t2.small"
    #   trusted_ip_ranges         = ["113.190.246.14/32"]
    #   public_key                = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICs90EoRM8hNt104FHGBor75TwIxH0YluFRXiEtBwSoR hr@DESKTOP-UR0DT47"
    #   assiate_public_ip_address = true
    # }
    # "do2504-jenkins-08" = {
    #   ec2InstanceName           = "do2504-jenkins-08"
    #   ec2ami                    = "ami-01dc51e87421923b6"
    #   ec2InstanceType           = "t2.medium"
    #   trusted_ip_ranges         = ["0.0.0.0/0"]
    #   public_key                = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICs90EoRM8hNt104FHGBor75TwIxH0YluFRXiEtBwSoR hr@DESKTOP-UR0DT47"
    #   assiate_public_ip_address = true
    #   ingress_rules = [
    #     {
    #       from_port   = 22
    #       to_port     = 22
    #       protocol    = "tcp"
    #       description = "SSH access"
    #     },
    #     {
    #       from_port   = 80
    #       to_port     = 80
    #       protocol    = "tcp"
    #       description = "HTTP access"
    #     },
    #     {
    #       from_port   = 443
    #       to_port     = 443
    #       protocol    = "tcp"
    #       description = "HTTPS access"
    #     },
    #     {
    #       from_port   = 8080
    #       to_port     = 8080
    #       protocol    = "tcp"
    #       description = "Jenkins web interface"
    #     }
    #   ]
    #   user_data = <<-EOF
    #         #!/bin/bash
    #         set -e
            
    #         # Update system
    #         yum update -y
            
    #         # Install Java 17 (required for Jenkins)
    #         yum install -y java-17-amazon-corretto-devel
            
    #         # Add Jenkins repository
    #         wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    #         rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
            
    #         # Install Jenkins
    #         yum install -y jenkins
            
    #         # Start and enable Jenkins
    #         systemctl start jenkins
    #         systemctl enable jenkins
            
    #         # Wait for Jenkins to start
    #         sleep 30
            
    #         # Get initial admin password and save to a file readable by ec2-user
    #         if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    #             cp /var/lib/jenkins/secrets/initialAdminPassword /home/ec2-user/jenkins-initial-password.txt
    #             chown ec2-user:ec2-user /home/ec2-user/jenkins-initial-password.txt
    #             chmod 644 /home/ec2-user/jenkins-initial-password.txt
    #         fi
            
    #         # Create a completion marker
    #         echo "Jenkins installation completed at $(date)" > /home/ec2-user/jenkins-install-complete.txt
    #         chown ec2-user:ec2-user /home/ec2-user/jenkins-install-complete.txt
    #     EOF
    # }
  }
}

variable "eks_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "do2504-eks-08"
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
  default     = "do2504-nodegr-08"
}

variable "default_tags" {
  default = {
    "terraform"  = "true",
    "created_by" = "hieptvh",
    "created_at" = "2026-01-04",
    "new_year"   = "2026"
  }
}