# ---------------------------------------------------------------------------------------------------------------------
# Deploy an EC2 instance for SimpleAD Administration (centos7-based image), with no high-availabity setup
# ---------------------------------------------------------------------------------------------------------------------
locals {
  vpc_security_group_ids_storage = []
  vpc_security_group_ids         = concat([aws_security_group.simple-ad-admin.id], local.vpc_security_group_ids_storage, var.domain_security_group_ids)
}
resource "aws_instance" "simple-ad-admin" {
  ami                    = var.aws_ami_id
  instance_type          = var.aws_instance_type
  iam_instance_profile   = var.iam_instance_profile
  subnet_id              = var.vpc.private_subnets_ids[0]
  vpc_security_group_ids = local.vpc_security_group_ids
  key_name               = var.aws_ssh_key_name
  root_block_device {
    delete_on_termination = true
    encrypted             = var.disk_root.encrypted
  }
  disable_api_termination = var.environment.resource_deletion_protection
  user_data = templatefile("${path.module}/user-data.yaml", {
    aws_region                        = var.aws_region,
    aws_zones                         = join(" ", var.aws_zones[*]),
    aws_ec2_instance_name             = local.name
    aws_ec2_instance_hostname_fqdn    = var.hostname_fqdn
    route53_enabled                   = var.route53_enabled ? "TRUE" : "FALSE"
    route53_direct_dns_update_enabled = var.route53_direct_dns_update_enabled ? "TRUE" : "FALSE"
    route53_private_hosted_zone_id    = var.route53_private_hosted_zone_id

    domain_host_name_short_ad_friendly = local.domain_host_name_short_ad_friendly
    domain_name                        = var.domain_name
    domain_realm_name                  = upper(var.domain_name)
    domain_netbios_name                = var.domain_netbios_name
    domain_join_user_name              = var.domain_join_user_name
    domain_join_user_password          = var.domain_join_user_password
    domain_login_allowed_groups        = join(",", var.domain_login_allowed_groups[*])
    domain_login_allowed_users         = join(",", var.domain_login_allowed_users[*])

    aws_efs_id                 = ""
    ebs_device_name            = "/dev/nvme1n1"
    aws_asg_name               = ""
    check_efs_asg_max_attempts = 0

    cloudwatch_enabled                           = var.cloudwatch_enabled ? "TRUE" : "FALSE"
    cloudwatch_refresh_interval_secs             = var.cloudwatch_refresh_interval_secs
    telegraf_enabled                             = var.telegraf_enabled ? "TRUE" : "FALSE"
    telegraf_influxdb_url                        = var.telegraf_influxdb_url
    telegraf_influxdb_password_secret_id         = var.telegraf_influxdb_password_secret_id
    telegraf_influxdb_retention_policy           = var.telegraf_influxdb_retention_policy
    telegraf_influxdb_https_insecure_skip_verify = var.telegraf_influxdb_https_insecure_skip_verify
  })
  tags = merge(var.global_default_tags, var.environment.default_tags, {
    Name                    = local.name
    HostNameShortADFriendly = local.domain_host_name_short_ad_friendly
    Zone                    = var.aws_zones[0]
    Visibility              = "private"
    Application             = "simple-ad-admin"
    ApplicationName         = var.name_suffix
  })
}
