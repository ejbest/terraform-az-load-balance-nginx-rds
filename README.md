# az-load-balance-nginx-rds

#### How to make this run
export two vars
<pre>
#access_key = <your access key>
#secret_key = <your secret_key>
</pre>
terraform fmt
<br>terraform init
<br>terraform validate
<br>terraform plan
<br>terraform apply

### RESULT - examples 
- us-east-1
- Multi (3) availability zones
- Applcation Load Balancer
- Nginx Server 
- Network ACL and Security Group usage
- Nat Gateways and Routing Tables

### Template 
- This repo will stand as a fair template and working ready to go model for any AWS VPC project.
- Can add any services, region, lambda, ecs, fargat, eks or otherwise servies or add regions.
- Start with this environment and expand and continue from here 
- see providers.tf and you can see how to integrate Hashicorp Vault 

Was part of a testing effort 

Goal was to create an nginx service that utilizes multi-az in AWS.  This web service must be accessable from a public IP.  Create a RDS Server that will the Web will have access.   All configurations must be as secure as possible (think of everything that must be done to make everything secure).  The web server needs to scale on-demand; whent the CPU load hits 65% or higher it needs to scale on-demand.  When the load is 40% or lower needs to scale down.

Of course this is a sandbox exercise and should not affect any items in AWS, so tag and name for your identification.  All infrastructure components must be created using Terraform.  OS and web application configrations does not need to be automated at this point.  

After Feedback #1 
- Only one NAT Gateway for all public subnets
- Using ELB 
- EC2 on public subnet and has public IP 
- EC2 and LB using same SG 

    "Think of why those configuration has issues and then. resolve them yourself.  Please get them correct and will check tomorrow"

1. Created a NAT gateway for each public subnets and different route tables and associate route tables to each subnet.

2. Moving to an ALB for it's more advanced features and routing capabilities compared to ELB.As well as content-based routing, advanced routing rules, SSL/TLS termination flexibility, or support for WebSockets and HTTPS.  ELB can still be a suitable and cost-effective option if you have a simple workload that requires basic load balancing at the transport layer.

3. Remove public IP from EC2 to prevent any access from internet to this EC2 nginx, so no ssh can established to EC2 from your internet

4. Separating the SG for EC2 and LB and will ensure that these two SG can access to each other.

Feedback continued to include the need for ACLs that were needed 
