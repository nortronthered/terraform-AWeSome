# Master infrastructure ref

provider "aws" {
    region = "${var.AWS_REGION}"
}


# Internet VPC
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags {
    Name        = "${var.ENVIRONMENT}-vpc"
    Environment = "${var.ENVIRONMENT}"
  }
}

# Subnets
resource "aws_subnet" "main-public-1" {
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2a"

  tags {
    Name        = "${var.ENVIRONMENT}-public-1"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_subnet" "main-public-2" {
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2b"

  tags {
    Name        = "${var.ENVIRONMENT}-public-2"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_subnet" "main-public-3" {
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2c"

  tags {
    Name        = "${var.ENVIRONMENT}-public-3"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_subnet" "main-private-1" {
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2a"

  tags {
    Name        = "${var.ENVIRONMENT}-private-1"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_subnet" "main-private-2" {
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2b"

  tags {
    Name        = "${var.ENVIRONMENT}-private-2"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_subnet" "main-private-3" {
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2c"

  tags {
    Name        = "${var.ENVIRONMENT}-private-3"
    Environment = "${var.ENVIRONMENT}"
  }
}

# Internet GW
resource "aws_internet_gateway" "main-gw" {
  vpc_id = "${aws_vpc.this.id}"

  tags {
    Name        = "main"
    Environment = "${var.ENVIRONMENT}"
  }
}

# NAT GW
resource "aws_eip" "nat"{
  count = 1

}

resource "aws_nat_gateway" "main-nat-gw" {
  allocation_id  = "${aws_eip.nat.id}"
  subnet_id      = "${aws_subnet.main-public-1.id}"
  depends_on     = ["aws_internet_gateway.main-gw"]

  tags {
    Name        = "${var.ENVIRONMENT}-nat-gw"
    Environment = "${var.ENVIRONMENT}"
  }
}

# route tables
resource "aws_route_table" "main-public" {
  vpc_id = "${aws_vpc.this.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main-gw.id}"
  }

  tags {
    Name        = "${var.ENVIRONMENT}-public-1"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_route_table" "main-private" {
  vpc_id = "${aws_vpc.this.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.main-nat-gw.id}"
  }

  tags {
    Name        = "${var.ENVIRONMENT}-private-1"
    Environment = "${var.ENVIRONMENT}"
  }
}

# route associations public
resource "aws_route_table_association" "main-public-1-a" {
  subnet_id      = "${aws_subnet.main-public-1.id}"
  route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_route_table_association" "main-public-2-a" {
  subnet_id      = "${aws_subnet.main-public-2.id}"
  route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_route_table_association" "main-public-3-a" {
  subnet_id      = "${aws_subnet.main-public-3.id}"
  route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_route_table_association" "main-private-1-a" {
  subnet_id      = "${aws_subnet.main-private-1.id}"
  route_table_id = "${aws_route_table.main-private.id}"
}

resource "aws_route_table_association" "main-private-2-a" {
  subnet_id      = "${aws_subnet.main-private-2.id}"
  route_table_id = "${aws_route_table.main-private.id}"
}

resource "aws_route_table_association" "main-private-3-a" {
  subnet_id      = "${aws_subnet.main-private-3.id}"
  route_table_id = "${aws_route_table.main-private.id}"
}
