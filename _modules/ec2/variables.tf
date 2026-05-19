variable "ec2InstanceName" {

}

variable "default_tags" {

}

variable "ec2ami" {

}

variable "ec2InstanceType" {

}

variable "vpc_subnet_id" {

}

variable "ec2key_name" {

}

variable "ec2key_public_key" {

}

variable "vpc_id" {
}

variable "trusted_ip_ranges" {
}


variable "assiate_public_ip_address" {

}

variable "tags" {

}

variable "my_aws_console_key" {
  description = "The name of the key pair to use"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules for security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access"
    }
  ]
}

variable "user_data" {
  description = "User data script to run on instance startup"
  type        = string
  default     = null
}