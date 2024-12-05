resource "aws_efs_file_system" "efs" {
  encrypted        = true
  performance_mode = "maxIO"

  lifecycle_policy {
    transition_to_ia = "AFTER_14_DAYS"
  }
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  tags = {
    Name     = "${var.name}-efs"
    Product  = "Datalabs"
    Customer = "${var.customer}"
  }
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "mount_target_a" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnets[0]
  security_groups = var.cluster_security_group_id
}

resource "aws_efs_mount_target" "mount_target_b" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnets[1]
  security_groups = var.cluster_security_group_id
}
