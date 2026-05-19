# Dùng key có sẵn:
data "aws_key_pair" "this" {
  key_name = var.my_aws_console_key # Ví dụ: "my-aws-console-key"
}