output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway"
  value       = aws_nat_gateway.nat.id
}

output "public_instance_ip" {
  description = "Public IP of the public instance"
  value       = aws_instance.public_instance.public_ip
}

output "private_instance_id" {
  description = "Instance ID of the private instance"
  value       = aws_instance.private_instance.id
}

output "public_security_group_id" {
  description = "ID of the public security group"
  value       = aws_security_group.public_sg.id
}

output "private_security_group_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private_sg.id
}
