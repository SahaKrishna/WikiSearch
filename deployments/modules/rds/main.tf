
resource "aws_db_subnet_group" "db_subnets" {
  name        = "${var.name}-${var.environment}-db"
  description = "DB subnets"
  subnet_ids  = var.rds_subnet_ids
}

resource "aws_iam_role" "enhanced_monitoring_role" {
  name = "${var.name}-${var.environment}-db"
  path = "/resource/rds/"

  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring_role.json
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = aws_iam_role.enhanced_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_security_group" "db_sg" {
  name        = "${var.name}-db"
  description = "controls access to the DB"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = var.rds_security_groups
  }

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "db" {
  name                    = "${replace(var.name,"-","")}db"
  identifier              = "${var.name}-${var.environment}-db"

  allocated_storage            = var.rds_storage
  allow_major_version_upgrade  = true
  apply_immediately            = "true"
  auto_minor_version_upgrade   = true
  backup_retention_period      = "0"
  copy_tags_to_snapshot        = "false"
  db_subnet_group_name         = aws_db_subnet_group.db_subnets.name
  engine                       = "mysql"
  engine_version               = var.rds_engine_version
  instance_class               = var.rds_type
  monitoring_interval          = "10"
  monitoring_role_arn          = aws_iam_role.enhanced_monitoring_role.arn
  multi_az                     = "false"
  password                     = var.rds_admin_pw
  performance_insights_enabled = true
  publicly_accessible          = true
  skip_final_snapshot          = "true"
  storage_encrypted            = "true"
  storage_type                 = "gp2"
  username                     = var.rds_username
  vpc_security_group_ids       = [aws_security_group.db_sg.id]
}
