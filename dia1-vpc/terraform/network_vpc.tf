data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

#=====================================
#      SUBNETS (Distribución AZ)
#=====================================

# Subnets Públicas
resource "aws_subnet" "public" {
  count                   = length(var.Public_subnet_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.Public_subnet_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                     = "${local.name_prefix}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  })
}

# Subnets Privadas
resource "aws_subnet" "private" {
  count             = length(var.Private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.Private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = merge(local.common_tags, {
    Name                              = "${local.name_prefix}-private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
  })
}
