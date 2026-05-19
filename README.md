# Terraform AWS Infrastructure Project

## 📖 Giới thiệu

Project này sử dụng Terraform để triển khai infrastructure trên AWS bao gồm:
- **VPC** với public và private subnets
- **NAT Gateway** và **Internet Gateway**
- **EC2 instances** với security groups
- **SSH Key pairs** cho remote access

Project được tổ chức theo kiến trúc module và hỗ trợ nhiều môi trường (dev, prod) thông qua Terraform workspaces.

## 📁 Cấu trúc thư mục

```
terraform-demo/
├── _modules/                    # Terraform modules
│   ├── vpc/                    # Module VPC
│   │   ├── data.tf
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   └── ec2/                    # Module EC2
│       ├── data.tf
│       ├── main.tf
│       ├── output.tf
│       └── variables.tf
├── envtfvars/                   # Biến cho từng môi trường
│   ├── dev.tfvars              # Cấu hình cho môi trường dev
│   └── prod.tfvars             # Cấu hình cho môi trường prod
├── main.tf                      # File chính gọi các modules
├── variables.tf                 # Khai báo biến root
├── output.tf                    # Output values
├── provider.tf                  # AWS provider configuration
├── deploy-infra.sh             # Script tự động deploy
└── README.md                    # File này
```

## ⚙️ Prerequisites

Trước khi bắt đầu, đảm bảo bạn đã cài đặt:

1. **Terraform** (version >= 1.0)
   ```bash
   terraform --version
   ```

2. **AWS CLI** đã được cấu hình
   ```bash
   aws configure
   # Nhập AWS Access Key ID, Secret Access Key, Region
   ```

3. **Quyền AWS cần thiết:**
   - EC2 (create, delete instances, key pairs, security groups)
   - VPC (create, delete VPC, subnets, route tables)
   - IAM (nếu cần tạo roles)

4. **Bash shell** (cho script tự động)

## 🚀 Cách sử dụng

### Phương án 1: Sử dụng Script tự động (Khuyến nghị)

Script `deploy-infra.sh` sẽ tự động xử lý tất cả các bước từ init đến apply.

#### Bước 1: Cấp quyền thực thi cho script

```bash
chmod +x deploy-infra.sh
```

#### Bước 2: Chạy script

```bash
./deploy-infra.sh
```

#### Bước 3: Làm theo hướng dẫn

Script sẽ hỏi các câu hỏi sau:

1. **Chọn workspace (dev hoặc prod):**
   ```
   Please enter the workspace (dev or prod):
   dev
   ```

2. **Nếu workspace chưa tồn tại**, script sẽ hỏi có tạo mới không:
   ```
   Invalid workspace. Create new workspace? (y/n)
   y
   ```

3. **Review kế hoạch** sau khi chạy `terraform plan`

4. **Xác nhận apply:**
   ```
   Do you want to apply the infrastructure? (y/n)
   y
   ```

Script sẽ tự động:
- Kiểm tra và tạo workspace nếu cần
- Chạy `terraform init`
- Chạy `terraform plan` với file tfvars tương ứng
- Chạy `terraform apply` nếu bạn đồng ý

---

### Phương án 2: Sử dụng Terraform Commands thủ công

Nếu bạn muốn kiểm soát từng bước chi tiết hơn.

#### Bước 1: Khởi tạo Terraform

```bash
terraform init
```

**Giải thích:** Download các providers (AWS) và modules cần thiết.

#### Bước 2: Tạo và chọn workspace

**Xem danh sách workspace hiện có:**
```bash
terraform workspace list
```

**Tạo workspace mới (nếu chưa có):**
```bash
# Tạo workspace dev
terraform workspace new dev

# Tạo workspace prod
terraform workspace new prod
```

**Chuyển đổi giữa các workspace:**
```bash
# Chuyển sang dev
terraform workspace select dev

# Chuyển sang prod
terraform workspace select prod
```

**Kiểm tra workspace hiện tại:**
```bash
terraform workspace show
```

#### Bước 3: Format code (optional)

```bash
terraform fmt -recursive
```

**Giải thích:** Tự động format lại code theo chuẩn Terraform.

#### Bước 4: Validate cấu hình

```bash
terraform validate
```

**Giải thích:** Kiểm tra cú pháp và tính hợp lệ của các file Terraform.

#### Bước 5: Xem kế hoạch thực thi

```bash
# Cho môi trường dev
terraform plan -var-file="envtfvars/dev.tfvars"

# Cho môi trường prod
terraform plan -var-file="envtfvars/prod.tfvars"
```

**Giải thích:** Xem preview những gì Terraform sẽ tạo/sửa/xóa mà không thực sự thực thi.

**Output sẽ hiển thị:**
- Số lượng resources sẽ được tạo (create)
- Số lượng resources sẽ được cập nhật (update)
- Số lượng resources sẽ được xóa (destroy)

#### Bước 6: Apply infrastructure

```bash
# Cho môi trường dev
terraform apply -var-file="envtfvars/dev.tfvars"

# Cho môi trường prod
terraform apply -var-file="envtfvars/prod.tfvars"
```

**Giải thích:** Thực thi kế hoạch và tạo infrastructure thực sự trên AWS.

**Lưu ý:** Terraform sẽ hỏi xác nhận, gõ `yes` để tiếp tục.

**Hoặc tự động approve (không hỏi):**
```bash
terraform apply -var-file="envtfvars/dev.tfvars" -auto-approve
```

#### Bước 7: Xem outputs

```bash
terraform output
```

**Output sẽ hiển thị:**
- VPC ID
- VPC CIDR block
- EC2 instance IDs

#### Bước 8: Xóa infrastructure (khi không dùng nữa)

```bash
# Xóa môi trường dev
terraform workspace select dev
terraform destroy -var-file="envtfvars/dev.tfvars"

# Xóa môi trường prod
terraform workspace select prod
terraform destroy -var-file="envtfvars/prod.tfvars"
```

**Lưu ý:** Cẩn thận với lệnh này! Nó sẽ xóa toàn bộ infrastructure.

---

## 🔄 Quản lý Workspace

### Khái niệm Workspace

Terraform workspace cho phép bạn quản lý nhiều môi trường (dev, staging, prod) từ cùng một bộ code mà không cần duplicate.

### Các lệnh Workspace thường dùng

```bash
# Liệt kê tất cả workspaces
terraform workspace list

# Tạo workspace mới
terraform workspace new <tên-workspace>

# Chuyển sang workspace khác
terraform workspace select <tên-workspace>

# Xem workspace hiện tại
terraform workspace show

# Xóa workspace
terraform workspace delete <tên-workspace>
```

### State file theo Workspace

Mỗi workspace có state file riêng trong thư mục:
```
terraform.tfstate.d/
├── dev/
│   └── terraform.tfstate
└── prod/
    └── terraform.tfstate
```

**Quan trọng:** Không được xóa hoặc edit thủ công các file state!

---

## 📝 Cấu hình môi trường

### Cấu trúc file `.tfvars`

Mỗi môi trường có file cấu hình riêng trong thư mục `envtfvars/`:

**`envtfvars/dev.tfvars`:**
```hcl
vpc_cidr_block = "10.0.0.0/16"
vpc_name = "vpc-dev"

ec2instances = {
    "vm1" = {
       ec2InstanceName = "vm1-dev"
       ec2ami = "ami-06571d6ae17e327ff"
       ec2InstanceType = "t2.micro"
       trusted_ip_ranges = ["113.190.246.2/32"]
       public_key = "ssh-ed25519 AAAA..."
       assiate_public_ip_address = false
    },
    "vm2" = {
       ec2InstanceName = "vm2-dev"
       ec2ami = "ami-06571d6ae17e327ff"
       ec2InstanceType = "t2.small"
       trusted_ip_ranges = ["113.190.246.2/32"]
       public_key = "ssh-ed25519 AAAA..."
       assiate_public_ip_address = true
    }
}
```

**`envtfvars/prod.tfvars`:**
```hcl
vpc_name = "vpc-prod"

ec2instances = {
    "vm1" = {
       ec2InstanceName = "vm1-prod"
       ec2InstanceType = "t2.small"     # Mạnh hơn dev
       ...
    },
    "vm2" = {
       ec2InstanceName = "vm2-prod"
       ec2InstanceType = "t2.medium"    # Mạnh hơn dev
       ...
    }
}
```

### Tùy chỉnh cấu hình

1. **Thay đổi CIDR block của VPC:**
   ```hcl
   vpc_cidr_block = "10.1.0.0/16"  # Thay đổi trong .tfvars
   ```

2. **Thêm/Xóa EC2 instances:**
   ```hcl
   ec2instances = {
       "vm1" = { ... },
       "vm2" = { ... },
       "vm3" = { ... }  # Thêm VM thứ 3
   }
   ```

3. **Thay đổi instance type:**
   ```hcl
   ec2InstanceType = "t2.large"  # Nâng cấp từ t2.micro
   ```

4. **Thay đổi trusted IP ranges (whitelist SSH):**
   ```hcl
   trusted_ip_ranges = ["113.190.246.2/32", "1.2.3.4/32"]
   ```

5. **Thêm public key mới:**
   ```bash
   # Tạo SSH key mới
   ssh-keygen -t ed25519 -C "your_email@example.com"
   
   # Copy public key vào .tfvars
   cat ~/.ssh/id_ed25519.pub
   ```

---

## 🔍 Kiểm tra Infrastructure

### Kiểm tra trên AWS Console

1. **VPC:** AWS Console → VPC → Your VPCs → Tìm `vpc-dev` hoặc `vpc-prod`
2. **Subnets:** VPC → Subnets → Xem public/private subnets
3. **EC2:** EC2 → Instances → Tìm `vm1-dev`, `vm2-dev`, etc.
4. **Security Groups:** EC2 → Security Groups

### Kiểm tra qua Terraform

```bash
# Xem state hiện tại
terraform show

# Xem chi tiết một resource cụ thể
terraform state show module.vpc.aws_vpc.this
terraform state show 'module.ec2instance["vm1"].aws_instance.this'

# List tất cả resources
terraform state list
```

### SSH vào EC2 instances

```bash
# Lấy public IP từ AWS Console hoặc terraform output

# SSH vào instance (với private key tương ứng)
ssh -i ~/.ssh/id_ed25519 ec2-user@<PUBLIC_IP>
```

---

## ⚠️ Lưu ý quan trọng

### 1. State File Management

- ✅ **Nên:** Dùng remote backend (S3 + DynamoDB) cho production
- ❌ **Không:** Commit file `.tfstate` vào Git
- ❌ **Không:** Edit thủ công file state

### 2. Credentials

- ❌ **Không commit** AWS credentials vào Git
- ✅ **Nên:** Dùng AWS CLI credentials hoặc IAM roles
- ✅ **Nên:** Thêm `.gitignore`:
  ```
  # .gitignore
  *.tfstate
  *.tfstate.*
  *.tfvars.backup
  .terraform/
  .terraform.lock.hcl
  ```

### 3. Cost Management

- ⚠️ Các resources này **tốn phí**:
  - NAT Gateway (~$0.045/hour + data transfer)
  - EC2 instances (tùy instance type)
  - Elastic IPs (nếu không attach vào instance đang chạy)
  
- 💡 **Tiết kiệm chi phí:**
  ```bash
  # Xóa infrastructure khi không dùng
  terraform destroy -var-file="envtfvars/dev.tfvars"
  ```

### 4. Security Best Practices

- 🔒 **SSH Access:** Luôn hạn chế `trusted_ip_ranges` chỉ IP của bạn
- 🔒 **Private Key:** Không commit private key vào Git
- 🔒 **Security Groups:** Review lại rules trước khi apply

### 5. Workspace

- ✅ **Luôn check** workspace hiện tại trước khi apply:
  ```bash
  terraform workspace show
  ```
- ⚠️ Nhầm workspace có thể dẫn đến apply nhầm môi trường!

### 6. Terraform Commands Best Practices

```bash
# Workflow chuẩn
terraform fmt          # Format code
terraform validate     # Validate syntax
terraform plan         # Review changes
terraform apply        # Apply changes

# Trước khi push code
terraform fmt -check   # Check format
terraform validate     # Validate
```

---

## 🐛 Troubleshooting

### Lỗi: "Error: Invalid workspace"

**Giải pháp:**
```bash
terraform workspace new dev
terraform workspace select dev
```

### Lỗi: "Error: Insufficient permissions"

**Nguyên nhân:** AWS credentials không có đủ quyền.

**Giải pháp:**
1. Kiểm tra AWS credentials: `aws sts get-caller-identity`
2. Đảm bảo IAM user/role có đủ quyền VPC và EC2

### Lỗi: "Error: VPC with CIDR xxx already exists"

**Nguyên nhân:** VPC với CIDR block đó đã tồn tại.

**Giải pháp:**
1. Xóa VPC cũ, hoặc
2. Thay đổi CIDR block trong `.tfvars`

### Lỗi: "Error: AMI not found"

**Nguyên nhân:** AMI ID không tồn tại trong region đang dùng.

**Giải pháp:**
1. Vào AWS Console → EC2 → AMI Catalog
2. Tìm AMI mới (Amazon Linux 2023)
3. Copy AMI ID mới vào `.tfvars`

### Script `deploy-infra.sh` không chạy

**Giải pháp:**
```bash
# Cấp quyền thực thi
chmod +x deploy-infra.sh

# Kiểm tra bash syntax
bash -n deploy-infra.sh
```

---

## 📚 Tài liệu tham khảo

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

## 👤 Tác giả

- **Created by:** hieptvh
- **Created at:** 2025-12-24
- **Updated:** 2026-01-03

---

## 🚀 AWS Load Balancer Controller Setup

Project này đã được cấu hình để hỗ trợ AWS Load Balancer Controller (ALB Controller) cho EKS cluster.

### 📋 Tổng quan

AWS Load Balancer Controller giúp bạn:
- Tự động tạo Application Load Balancer (ALB) khi deploy Kubernetes Ingress
- Tự động tạo Network Load Balancer (NLB) khi expose Kubernetes Service
- Quản lý Target Groups và các tài nguyên AWS liên quan

### 🔧 Những gì đã được setup bởi Terraform

Khi chạy `terraform apply`, các tài nguyên sau sẽ được tạo:

1. **EKS Cluster** với OIDC Provider được enable (`enable_irsa = true`)
2. **IAM Policy** cho ALB Controller với các quyền cần thiết
3. **IAM Role** với trust relationship đến OIDC Provider của EKS
4. **Policy Attachment** liên kết IAM Role và Policy

### 📝 Cài đặt ALB Controller

Sau khi `terraform apply` thành công, chạy script để cài đặt ALB Controller:

```bash
# Cấp quyền thực thi (chỉ cần lần đầu)
chmod +x install-alb-controller.sh

# Chạy script cài đặt
./install-alb-controller.sh
```

### 🔍 Script sẽ tự động:

1. ✅ Lấy thông tin từ Terraform outputs (cluster name, IAM role ARN)
2. ✅ Cấu hình `kubectl` để kết nối với EKS cluster
3. ✅ Tạo Kubernetes Service Account với annotation IAM role
4. ✅ Thêm AWS EKS Helm repository
5. ✅ Cài đặt AWS Load Balancer Controller qua Helm chart
6. ✅ Verify cài đặt thành công

### 📊 Kiểm tra sau khi cài đặt

```bash
# Kiểm tra deployment
kubectl get deployment -n kube-system aws-load-balancer-controller

# Kiểm tra pods
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Xem logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

**Expected output:**
```
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           2m
```

### 🌐 Sử dụng ALB Controller

Sau khi cài đặt thành công, bạn có thể tạo Ingress resources:

**Example Ingress:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```

**Apply ingress:**
```bash
kubectl apply -f ingress.yaml

# Xem ALB được tạo
kubectl get ingress
kubectl describe ingress my-ingress
```

### 🔗 Terraform Outputs liên quan

```bash
# Xem IAM Role ARN
terraform output alb_controller_iam_role_arn

# Xem EKS cluster name
terraform output eks_cluster_id

# Xem OIDC Provider ARN
terraform output eks_oidc_provider_arn
```

### 🛠️ Troubleshooting

#### ALB Controller pods không start

```bash
# Xem logs chi tiết
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Kiểm tra IAM role annotations
kubectl describe sa -n kube-system aws-load-balancer-controller
```

#### Ingress không tạo ALB

```bash
# Kiểm tra ingress events
kubectl describe ingress <ingress-name>

# Kiểm tra controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller --tail=50
```

#### Script báo lỗi "Failed to get Terraform outputs"

**Giải pháp:**
- Đảm bảo đã chạy `terraform apply` thành công trước
- Chạy script từ thư mục `terraform-infra/`

### 📚 Tài liệu tham khảo

- [AWS Load Balancer Controller Documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [AWS Load Balancer Controller GitHub](https://github.com/kubernetes-sigs/aws-load-balancer-controller)
- [Ingress Annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.11/guide/ingress/annotations/)

### ⚠️ Lưu ý quan trọng

1. **Cost:** ALB sẽ tốn phí (~$0.0225/hour + LCU charges). Nhớ xóa khi không dùng.
2. **Permissions:** IAM role được tạo có full permissions để quản lý ALB/NLB trong tài khoản AWS của bạn.
3. **Cleanup:** Khi chạy `terraform destroy`, nhớ xóa tất cả Ingress resources trước để tránh ALB bị orphaned.

```bash
# Xóa tất cả ingress trước khi destroy
kubectl delete ingress --all -A

# Uninstall ALB controller
helm uninstall aws-load-balancer-controller -n kube-system

# Sau đó mới chạy terraform destroy
terraform destroy -var-file="envtfvars/dev.tfvars"
```

---

## 📄 License

Project này dùng cho mục đích học tập và demo.

