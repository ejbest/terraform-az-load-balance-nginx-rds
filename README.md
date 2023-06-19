# az-load-balance-nginx-rds

Goal is to create an nginx service that utilizes multi-az in AWS.  This web service must be accessable from a public IP.  Create a RDS Server that will the Web will have access.   All configurations must be as secure as possible (think of everything that must be done to make everything secure).  The web server needs to scale on-demand; whent the CPU load hits 65% or higher it needs to scale on-demand.  When the load is 40% or lower needs to scale down.

Of course this is a sandbox exercise and should not affect any items in AWS, so tag and name for your identification.  All infrastructure components must be created using Terraform.  OS and web application configrations does not need to be automated at this point.  

Of course this is a sandbox exercise and should not affect any items in AWS, so tag and name for your identification.  All infrastructure components must be created using Terraform.  OS and web application configrations does not need to be automated at this point.  
