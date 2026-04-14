# =============================
#         VPC
# =============================

output "vpc_id" {
  description = "ID de la VPC principal"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block de la VPC"
  value       = aws_vpc.main.cidr_block
}

# =============================
#      INTERNET GATEWAY
# =============================

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.gw.id
}

# =============================
#      SUBNETS PÚBLICAS
# =============================

output "public_subnet_ids" {
  description = "Lista de IDs de las subnets públicas"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "Lista de CIDRs de las subnets públicas"
  value       = aws_subnet.public[*].cidr_block
}

# =============================
#      SUBNETS PRIVADAS
# =============================

output "private_subnet_ids" {
  description = "Lista de IDs de las subnets privadas"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "Lista de CIDRs de las subnets privadas"
  value       = aws_subnet.private[*].cidr_block
}

# =============================
#      AVAILABILITY ZONES
# =============================

output "availability_zones" {
  description = "Availability Zones disponibles en la región"
  value       = data.aws_availability_zones.available.names
}

# =============================
#      EC2 INSTANCE
# =============================

output "test_server_public_ip" {
  description = "IP pública del servidor de prueba"
  value       = aws_instance.web_test.public_ip
}

output "test_server_private_ip" {
  description = "IP privada del servidor de prueba"
  value       = aws_instance.web_test.private_ip
}

# =============================
#           RDS / DB
# =============================

output "rds_hostname" {
  description = "DNS endpoint del RDS"
  value       = aws_db_instance.default.address
  sensitive   = true
}

output "rds_port" {
  description = "Puerto del RDS"
  value       = aws_db_instance.default.port
}

output "rds_endpoint" {
  description = "Endpoint completo (host:port) del RDS"
  value       = aws_db_instance.default.endpoint
  sensitive   = true
}

# =============================
#           ALB
# =============================

output "alb_dns_name" {
  description = "DNS público del Application Load Balancer (usar para acceder a la app)"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN del Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_target_group_arn" {
  description = "ARN del Target Group"
  value       = aws_lb_target_group.web.arn
}
