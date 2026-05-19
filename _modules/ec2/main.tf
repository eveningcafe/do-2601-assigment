locals {
  current_workspace = terraform.workspace
}

# resource "aws_key_pair" "this" {
#     key_name = "${var.ec2InstanceName}-vmkey"
#     public_key = var.ec2key_public_key
#     tags = merge({
#         "Name" = var.ec2InstanceName
#     }, var.default_tags)
# }

resource "aws_security_group" "this" {
  name        = "${var.ec2InstanceName}-sg"
  description = "default security group for ${var.ec2InstanceName}"
  vpc_id      = var.vpc_id
  tags = merge({
    "Name" = "${var.ec2InstanceName}-sg"
  })
}

// rule of security group (ssh access from the internet)
resource "aws_security_group_rule" "sg-rule-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  ipv6_cidr_blocks  = null
  prefix_list_ids   = null
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "sg-rule-ingress" {
  for_each = { for idx, rule in(var.ingress_rules != null ? var.ingress_rules : [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access"
    }
  ]) : idx => rule }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = var.trusted_ip_ranges
  security_group_id = aws_security_group.this.id
  description       = each.value.description
}

// create ec2 instance
resource "aws_instance" "this" {
  ami                         = var.ec2ami
  instance_type               = var.ec2InstanceType
  subnet_id                   = var.vpc_subnet_id
  key_name                    = data.aws_key_pair.this.key_name
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = var.assiate_public_ip_address
  user_data                   = var.user_data
  user_data_replace_on_change = true
  tags = merge({
    "Name" = var.ec2InstanceName
    "Env"  = local.current_workspace
  }, var.default_tags)
}
