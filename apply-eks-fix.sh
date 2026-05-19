#!/bin/bash
set -e

echo "=========================================="
echo "Apply EKS với workaround cho bug count"
echo "=========================================="
echo ""

echo "Bước 1: Apply Security Groups..."
terraform apply -auto-approve \
  -target=aws_security_group.eks_nodes_sg \
  -target=aws_security_group.rds_sg

echo ""
echo "Bước 2: Apply toàn bộ..."
terraform apply -auto-approve

echo ""
echo "✅ Hoàn thành!"
