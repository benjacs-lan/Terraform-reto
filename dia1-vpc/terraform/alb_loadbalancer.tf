# =============================
#    SECURITY GROUP - ALB
# =============================

resource "aws_security_group" "alb_sg" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group para el Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # Permitir tráfico HTTP entrante desde cualquier lugar (internet)
  ingress {
    description = "HTTP desde internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir todo el tráfico saliente (para llegar a las instancias)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

# =============================
#   APPLICATION LOAD BALANCER
# =============================

resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false          # false = internet-facing (público)
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  # El ALB vive en las subnets públicas para recibir tráfico de internet
  subnets = aws_subnet.public[*].id

  enable_deletion_protection = false  # En prod: true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

# =============================
#       TARGET GROUP
# =============================

# El Target Group define a qué instancias/puertos enviar el tráfico
# y cómo verificar que están sanas (Health Check)
resource "aws_lb_target_group" "web" {
  name     = "${local.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # Health Check: el ALB golpea este endpoint para saber si la app está viva
  health_check {
    enabled             = true
    path                = "/"          # Endpoint a chequear
    port                = "traffic-port" # Usa el mismo puerto del TG (80)
    protocol            = "HTTP"
    matcher             = "200"        # HTTP 200 = instancia sana
    interval            = 30           # Cada 30s hace el chequeo
    timeout             = 5            # Falla si no responde en 5s
    healthy_threshold   = 2            # 2 éxitos = marca como sana
    unhealthy_threshold = 3            # 3 fallos = marca como no sana
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-tg"
  })
}

# Registrar la instancia de prueba en el Target Group
resource "aws_lb_target_group_attachment" "web_test" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web_test.id
  port             = 80
}

# =============================
#         LISTENER
# =============================

# El Listener "escucha" en el puerto 80 del ALB y decide a dónde
# enrutar el tráfico (en este caso, al Target Group)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Acción por defecto: reenviar al Target Group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-listener-http"
  })
}
