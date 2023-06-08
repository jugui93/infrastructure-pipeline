output "ec2_public_ip" {
  description = "public IP address for EC2 instance"
  value       = aws_instance.http_server1.public_ip
}

output "ec2_ami" {
  description = "AMI of the EC2 instance"
  value       = aws_instance.http_server1.ami
}
output "ec2_type" {
  description = "type of the EC2 instance"
  value       = aws_instance.http_server1.instance_type
}

output "public_vpc_id" {
  description = "ID of the VPC's public"
  value       = aws_vpc.main.id
}
output "ec2_subnet_id" {
  description = "ID of the VPC's public subnet"
  value       = aws_subnet.public_subnetA.id
}
output "public_subnet_AZ" {
  description = "Availability zone of the VPC's public subnet"
  value       = aws_subnet.public_subnetA.id
}
output "ec2_region" {
  description = "The AWS region of the EC2"
  value       = data.aws_region.current.name
}
