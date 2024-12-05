data "aws_availability_zones" "available" {}

resource "random_shuffle" "public_az" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnet
}

resource "aws_subnet" "public_subnets" {
  count             = var.public_sn_count
  vpc_id            = var.vpc_id
  cidr_block        = var.public_cidrs[count.index]
  availability_zone = random_shuffle.public_az.result[count.index]

  tags = {
    Name     = "${var.name}-eks-public-subnet-${count.index + 1}"
    Product  = "Datalabs"
    Customer = "${var.customer}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = var.public_sn_count
  vpc_id            = var.vpc_id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = random_shuffle.public_az.result[count.index]

  tags = {
    Name     = "${var.name}-eks-private-subnet-${count.index + 1}"
    Product  = "Datalabs"
    Customer = "${var.customer}"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.public_subnets.*.id[count.index]
  route_table_id = var.public_rtb_id
}

resource "aws_route_table_association" "private_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.private_subnets.*.id[count.index]
  route_table_id = var.private_rtb_id
}
