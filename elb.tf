resource "aws_security_group" "elb" {
  name 	      = "elb-security-group"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "ELB security group"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "cert" {
  key_algorithm         = "RSA"
  private_key_pem       = "${tls_private_key.key.private_key_pem}"
  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["*.us-east-1.elb.amazonaws.com"]

  subject {
    common_name  = "*.us-east-1.elb.amazonaws.com"
    organization = "ORG"
    province     = "STATE"
    country      = "US"
  }
}

resource "aws_acm_certificate" "cert" {
  private_key      = "${tls_private_key.key.private_key_pem}"
  certificate_body = "${tls_self_signed_cert.cert.cert_pem}"
}

resource "aws_elb" "elb" {
  name = "elb"
  security_groups = ["${aws_security_group.elb.id}"]
  subnets = local.ec2_subnet_list
  instances = aws_instance.ubuntu_server.*.id

  listener {
    lb_port = 80
    lb_protocol = "tcp"
    instance_port = 80
    instance_protocol = "tcp"
  }
  listener {
    instance_port      = 443
    instance_protocol  = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${aws_acm_certificate.cert.arn}"
  }

  idle_timeout	      = 400
  connection_draining = true
  connection_draining_timeout = 400
}
