resource "tls_private_key" "EJB-key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "EJB-cert" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.EJB-key.private_key_pem
  #private_key_pem      = "${tls_private_key.key.private_key_pem}"
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

resource "aws_acm_certificate" "EJB-cert" {
  #private_key      = "${tls_private_key.key.private_key_pem}"
  #certificate_body = "${tls_self_signed_cert.cert.cert_pem}"
  private_key      = tls_private_key.EJB-key.private_key_pem
  certificate_body = tls_self_signed_cert.EJB-cert.cert_pem
}

resource "aws_lb" "EJB-alb" {
  name               = "EJB-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.EJB-lb.id]
  subnets            = local.ec2_subnet_list
}


resource "aws_lb_target_group" "EJB_https" {
  name        = "EJB-https"
  target_type = "instance"
  port        = "443"
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.EJB_vpc.id

  health_check {
    path     = "/"
    port     = "443"
    protocol = "HTTPS"
    matcher  = "200,404"
  }
}

resource "aws_lb_listener" "EJB_https" {
  load_balancer_arn = aws_lb.EJB-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.EJB-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.EJB_https.arn
  }
}

#resource "aws_elb" "EJB-elb" {
#  name = "elb"
#  #security_groups = ["${aws_security_group.elb.id}"]
#  security_groups = [aws_security_group.EJB-web-app.id]
#  subnets         = local.ec2_subnet_list
#  health_check {
#    healthy_threshold   = 2
#    unhealthy_threshold = 2
#    timeout             = 3
#    target              = "HTTPS:443/"
#    interval            = 15
#  }
#  #instances = aws_instance.ubuntu_server.*.id
#
#  #listener {
#  #  lb_port = 80
#  #  lb_protocol = "tcp"
#  #  instance_port = 80
#  #  instance_protocol = "tcp"
#  #}
#  listener {
#    instance_port     = 443
#    instance_protocol = "https"
#    lb_port           = 443
#    lb_protocol       = "https"
#    #ssl_certificate_id = "${aws_acm_certificate.cert.arn}"
#    ssl_certificate_id = aws_acm_certificate.EJB-cert.arn
#  }
#
#  idle_timeout                = 400
#  connection_draining         = true
#  connection_draining_timeout = 400
#}
