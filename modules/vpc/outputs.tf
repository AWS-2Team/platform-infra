output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "db_subnet_ids" {
  value = [for s in aws_subnet.db : s.id]
}

output "eks_security_group_id" {
  value = aws_security_group.eks.id
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion.id
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "bastion_role_arn" {
  value = aws_iam_role.bastion.arn
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
