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

resource "aws_security_group" "eks" {
  name        = "${var.name}-eks-sg"
  description = "Security group for EKS resources"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "Allow kubectl from bastion"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "Allow kubectl from bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-eks-sg"
  }
}

resource "aws_security_group" "bastion" {
  name        = "${var.name}-bastion-sg"
  description = "Security group for SSM-managed bastion"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-bastion-sg"
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "bastion" {
  name_prefix = "${var.name}-bastion-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "bastion_eks" {
  name = "${var.name}-bastion-eks"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "bastion" {
  name_prefix = "${var.name}-bastion-"
  role        = aws_iam_role.bastion.name
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[sort(keys(var.public_subnets))[0]].id
  private_ip                  = var.bastion_private_ip
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion.name

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf install -y amazon-ssm-agent awscli jq mariadb105 postgresql15
    systemctl enable --now amazon-ssm-agent
    curl -fsSL -o /tmp/kubectl "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
    rm -f /tmp/kubectl
  EOF

  tags = {
    Name = "${var.name}-bastion"
  }
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

resource "aws_subnet" "db" {
  for_each          = var.db_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${var.region}${each.key}"

  tags = {
    Name = "${var.name}-db-${each.key}"
    Tier = "db"
  }
}

locals {
  public_subnet_cidrs = [for k in sort(keys(var.public_subnets)) : var.public_subnets[k]]
  eks_subnet_cidrs    = [for k in sort(keys(var.private_subnets)) : var.private_subnets[k]]
  db_subnet_cidrs     = [for k in sort(keys(var.db_subnets)) : var.db_subnets[k]]
  bastion_cidr        = "${var.bastion_private_ip}/32"
}

resource "aws_network_acl" "main" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for s in aws_subnet.public : s.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.name}-public-nacl"
  }
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for s in aws_subnet.private : s.id]

  dynamic "ingress" {
    for_each = { for i, cidr in local.public_subnet_cidrs : i => cidr }

    content {
      protocol   = "tcp"
      rule_no    = 100 + tonumber(ingress.key)
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 80
      to_port    = 80
    }
  }

  dynamic "ingress" {
    for_each = { for i, cidr in local.public_subnet_cidrs : i => cidr }

    content {
      protocol   = "tcp"
      rule_no    = 200 + tonumber(ingress.key)
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 8080
      to_port    = 8080
    }
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = local.bastion_cidr
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 310
    action     = "allow"
    cidr_block = local.bastion_cidr
    from_port  = 8080
    to_port    = 8080
  }

  dynamic "ingress" {
    for_each = { for i, cidr in local.db_subnet_cidrs : i => cidr }

    content {
      protocol   = "tcp"
      rule_no    = 400 + tonumber(ingress.key)
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 1024
      to_port    = 65535
    }
  }

  dynamic "egress" {
    for_each = { for i, cidr in local.db_subnet_cidrs : i => cidr }

    content {
      protocol   = "tcp"
      rule_no    = 100 + tonumber(egress.key)
      action     = "allow"
      cidr_block = egress.value
      from_port  = 3306
      to_port    = 3306
    }
  }

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  dynamic "egress" {
    for_each = { for i, cidr in local.public_subnet_cidrs : i => cidr }

    content {
      protocol   = "tcp"
      rule_no    = 300 + tonumber(egress.key)
      action     = "allow"
      cidr_block = egress.value
      from_port  = 1024
      to_port    = 65535
    }
  }

  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = local.bastion_cidr
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "${var.name}-eks-nacl"
  }
}

resource "aws_network_acl" "db" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for s in aws_subnet.db : s.id]

  dynamic "ingress" {
    for_each = { for i, cidr in local.eks_subnet_cidrs : i => cidr }

    content {
      protocol   = "tcp"
      rule_no    = 100 + tonumber(ingress.key)
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 3306
      to_port    = 3306
    }
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = local.bastion_cidr
    from_port  = 3306
    to_port    = 3306
  }

  dynamic "egress" {
    for_each = { for i, cidr in local.eks_subnet_cidrs : i => cidr }

    content {
      protocol   = "tcp"
      rule_no    = 100 + tonumber(egress.key)
      action     = "allow"
      cidr_block = egress.value
      from_port  = 1024
      to_port    = 65535
    }
  }

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = local.bastion_cidr
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "${var.name}-db-nacl"
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

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name}-db-rt" }
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

resource "aws_route_table_association" "db" {
  for_each       = aws_subnet.db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.db.id
}
