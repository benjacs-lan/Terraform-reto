resource "aws_security_group" "db_sg" {
  name        = "${local.name_prefix}-db-sg"
  description = "Permitir traffic PostgreSQL desde el Web SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL desde el servidor web"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # Solo permitimos conexiones que vengan del Security Group de EC2
    security_groups = [aws_security_group.public_web.id]
  }

  tags = local.common_tags
}

# =============== Subnet Group ============
resource "aws_db_subnet_group" "db_group" {
  name       = "${local.name_prefix}-db-subnet-gp"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(local.common_tags, {
    Name = "Main DB Subnet GP"
  })

}

# ============ INstancia RDS ===========
resource "aws_db_instance" "default" {
  identifier        = "${local.name_prefix}-db"
  allocated_storage = 20
  db_name           = "my-db-local"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.micro"
  username          = "postgres"
  password          = var.db_passw

  # Conexion con la red y sg
  db_subnet_group_name   = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false

  tags = merge(local.common_tags, {
    Name = "Main DB Instance"
  })

}

