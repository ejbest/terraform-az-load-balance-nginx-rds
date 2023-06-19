
output "vpc_id" {
  description = "Output the ID for the primary VPC"
  value       = aws_vpc.EJB_vpc.id
}

output "rds_address" {
  value       = aws_db_instance.EJB_database.address
  description = "DB Address only accessible on nginx"

}
output "elb_dns" {
  description = "Public DNS ELB"
  value       = "https://${aws_elb.EJB-elb.dns_name}"
}

# output "elb_ip" {
#   description = "Public IP"
#   value       = aws_elb.elb.public_ip
# }

output "vpc_information" {
  description = "VPC Information about Environment"

  value = "Your ${aws_vpc.EJB_vpc.tags.Environment} VPC has an ID of ${aws_vpc.EJB_vpc.id}"
}

output "vpc_name" {
  description = "VPC Information about Environment"

  value = "vpc_name is: ${aws_vpc.EJB_vpc.tags.Name}"
}

output "private_key" {
  description = "Private Key"
  value       = "private_key name is: ${local_file.EJB_private_key_pem.filename}"
}


output "ssh_cmd" {
  description = "Private Key"
  value       = "ssh -i ${local_file.EJB_private_key_pem.filename} ubuntu@${data.aws_instances.EJB_ec2_instances.public_ips[0]}"
}

output "db_username" {
  description = "DB username"
  value       = var.EJB-rds_master_username
}


output "db_password" {
  description = "DB Password"
  value       = random_password.EJB-password.result
}
