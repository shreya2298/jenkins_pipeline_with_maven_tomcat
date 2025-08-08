resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "58.84.63.133/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "58.84.63.133/32"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
//For Jenkins UI access
resource "aws_vpc_security_group_ingress_rule" "allow_jenkins" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "58.84.63.133/32"
  from_port         = 8082
  to_port           = 8082
  ip_protocol       = "tcp"

  tags = {
    Name = "Allow Jenkins Port"
  }
}
//For Tomcat UI access
resource "aws_vpc_security_group_ingress_rule" "allow_tomcat" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "58.84.63.133/32"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"

  tags = {
    Name = "Allow Tomcat Port"
  }
}
