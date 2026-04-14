resource "aws_security_group" "public_web" {
  name        = "${local.name_prefix}-public-web"
  description = "Security group for public web servers"
  vpc_id      = aws_vpc.main.id

  # Reglas de entrada
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite tráfico HTTP desde cualquier lugar modifcar en casos de prod
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite tráfico SSH en casos reales la IP de la VPN, NUNCA 0.0.0.0/0
  }

  # Reglas de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Todos los protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-web"
  })
}

