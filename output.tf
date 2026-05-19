output "vpc_id" {
  description = "The vpc id"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The vpc cidr block"
  value       = module.vpc.vpc_cidr_block
}

output "ec2_instance_ids" {
  description = "The ids of the EC2 instances"
  value       = { for key, instance in module.ec2instance : key => instance.ec2_instance_id }
}

# ================== EKS Outputs ==================

output "eks_cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = module.eks.oidc_provider_arn
}

# ================== ALB Controller Outputs ==================

output "alb_controller_iam_role_arn" {
  description = "ARN of IAM role for AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}

output "alb_controller_iam_policy_arn" {
  description = "ARN of IAM policy for AWS Load Balancer Controller"
  value       = aws_iam_policy.alb_controller.arn
}

# ================== Security Group Outputs ==================

output "eks_nodes_security_group_id" {
  description = "Security Group ID của EKS worker nodes - DÙNG ĐỂ REFERENCE trong các services khác"
  value       = aws_security_group.eks_nodes_sg.id
}

output "rds_security_group_id" {
  description = "Security Group ID cho RDS - GẮN VÀO RDS khi tạo trên AWS Console"
  value       = aws_security_group.rds_sg.id
}

output "rds_security_group_name" {
  description = "Security Group Name cho RDS"
  value       = aws_security_group.rds_sg.name
}