output "hello-world" {
  description = "Print a Hello World text output"
  value       = "Hello World"
}
output "vpc_id" {
  description = "Output the ID for the primary VPC"
  value       = aws_vpc.vpc.id
}
output "public_url1" {
  description = "Public URL for our Ubuntu Server"
  value       = "https://${aws_instance.ubuntu_server[0].public_ip}"
}
output "public_url2" {
  description = "Public URL for our Ubuntu Server"
  value       = "https://${aws_instance.ubuntu_server[1].public_ip}"
}
output "public_url3" {
  description = "Public URL for our Ubuntu Server"
  value       = "https://${aws_instance.ubuntu_server[2].public_ip}"
}

output "elb_dns" {
  description = "Public DNS ELB"
  value = aws_elb.elb.dns_name
  
}
output "vpc_information" {
  description = "VPC Information about Environment"

  value = "Your ${aws_vpc.vpc.tags.Environment} VPC has an ID of ${aws_vpc.vpc.id}"
}

output "vpc_name" {
  description = "VPC Information about Environment"

  value = "vpc_name is: ${aws_vpc.vpc.tags.Name}"
}

# output "private_key" {
#   description = "Private Key"
#   value = "private_key name is: ${aws_vpc.private.key}"
# }
