# ---------------------------------------------------------------------------------------------------------------------
# Security Groups and Rules
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "simple-ad-admin" {
  name        = local.name
  description = "Simple AD Administration (linux)"
  vpc_id      = var.vpc.vpc_id
  tags = {
    Name            = local.name
    Application     = "simple-ad-admin"
    ApplicationName = var.name_suffix
  }
}
# All ingress to custom port 2022 (ssh)
resource "aws_security_group_rule" "simple-ad-admin-allow-ingress-ssh" {
  type              = "ingress"
  description       = "ssh"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ingress_cidrs.ssh
  security_group_id = aws_security_group.simple-ad-admin.id
}

# --------------------------------------- egress ------------------------------------------------------------------
# For yum updates
resource "aws_security_group_rule" "simple-ad-admin-allow-egress-http" {
  type              = "egress"
  description       = "http"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.http
  security_group_id = aws_security_group.simple-ad-admin.id
}
resource "aws_security_group_rule" "simple-ad-admin-allow-egress-https" {
  type              = "egress"
  description       = "https"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.https
  security_group_id = aws_security_group.simple-ad-admin.id
}
resource "aws_security_group_rule" "simple-ad-admin-allow-egress-telegraf-influxdb" {
  type              = "egress"
  description       = "telegraf agent to influxdb"
  from_port         = 8086
  to_port           = 8086
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.telegraf_influxdb
  security_group_id = aws_security_group.simple-ad-admin.id
}
