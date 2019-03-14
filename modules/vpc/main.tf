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
  subnet_id     = "${element(aws_subnet.subnets.*.id, count.index)}"

  tags = "${var.tags}"
}

# create private subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnets[count.index]}"

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

resource "aws_route_table_association" "private_rt" {
  count = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.subnets.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.rt.*.id, count.index)}"
}
