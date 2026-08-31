resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name}-igw" }
}

resource "aws_subnet" "public" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = "${var.region}${each.key}"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.name}-public-${each.key}"
    Tier                     = "public"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${var.region}${each.key}"

  tags = {
    Name                              = "${var.name}-private-${each.key}"
    Tier                              = "private"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# NAT 각 AZ 1개.
resource "aws_eip" "nat" {
  for_each = var.public_subnets
  domain   = "vpc"
  tags     = { Name = "${var.name}-nat-${each.key}" }
}

resource "aws_nat_gateway" "main" {
  for_each      = var.public_subnets
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags          = { Name = "${var.name}-nat-${each.key}" }
  depends_on    = [aws_internet_gateway.main]
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.name}-public-rt" }
}


resource "aws_route_table" "private" {
  for_each = var.private_subnets
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }
  tags = { Name = "${var.name}-private-${each.key}-rt" }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
