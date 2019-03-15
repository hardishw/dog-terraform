resource "aws_vpc" "main" {
  cidr_block = "${var.cidr_block}"

  tags = "${var.tags}"
}

# create igw
resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.main.id}"

  tags = "${var.tags}"
}

# create ngw
resource "aws_eip" "ngw_ip" {
  count = "${length(var.azs)}"
  vpc = true

  tags = "${var.tags}"
}

resource "aws_nat_gateway" "ngw" {
  count = "${length(var.azs)}"
  allocation_id = "${element(aws_eip.ngw_ip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.private.*.id, count.index)}"

  tags = "${var.tags}"
}

# create private subnets
resource "aws_subnet" "private" {
  count = "${length(var.private_subnets)}"
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index % length(var.azs))}"

  tags = "${var.tags}"
}

# create private route table
resource "aws_route_table" "private_rt" {
  count = "${length(var.azs)}"
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
  }

  tags = "${var.tags}"
}

resource "aws_route_table_association" "private_ra" {
  count = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_rt.*.id, count.index % length(var.azs))}"
}

# create private subnets
resource "aws_subnet" "public" {
  count = "${length(var.public_subnets)}"
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index % length(var.azs))}"

  tags = "${var.tags}"
}

# create private route table
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.this.id}"
  }

  tags = "${var.tags}"
}

resource "aws_route_table_association" "public_ra" {
  count = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}
