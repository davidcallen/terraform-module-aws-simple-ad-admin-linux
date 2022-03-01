resource "aws_ebs_volume" "simple-ad-admin-data-ebs" {
  count             = (var.disk_simple_ad_admin_home.enabled == false && var.disk_simple_ad_admin_home.type == "EBS") ? 1 : 0
  availability_zone = var.aws_zones[0]
  size              = var.disk_simple_ad_admin_home.size
  encrypted         = var.disk_simple_ad_admin_home.encrypted

  tags = merge(var.global_default_tags, var.environment.default_tags, {
    Name                    = "${local.name}-data"
    HostNameShortADFriendly = local.domain_host_name_short_ad_friendly
    Zone                    = var.aws_zones[0]
    Visibility              = "private"
    Application             = "simple-ad-admin"
    ApplicationName         = var.name_suffix
  })
}

resource "aws_volume_attachment" "simple-ad-admin-data-ebs" {
  count       = (var.disk_simple_ad_admin_home.enabled == false && var.disk_simple_ad_admin_home.type == "EBS") ? 1 : 0
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.simple-ad-admin-data-ebs[0].id
  instance_id = aws_instance.simple-ad-admin.id
}
