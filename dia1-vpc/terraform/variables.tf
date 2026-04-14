variable "environment" {
  type        = string
  description = "El entorno de despliegue es en testing"
  default     = "lab"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block para la VPC"
  default     = "10.0.0.0/16"
}

variable "Public_subnet_cidr" {
  type        = list(string)
  description = "CIDR block para subnets publicas"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "Private_subnet_cidr" {
  type        = list(string)
  description = "CIDR block para subnets privadas"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_passw" {
  description = "Password for DB"
  type        = string
  sensitive   = true
}

