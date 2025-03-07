### **1. Отримання інформації про існуючий VPC**
data "aws_vpc" "default" {
  default = true
}

output "vpc_id" {
  value = data.aws_vpc.default.id
}
