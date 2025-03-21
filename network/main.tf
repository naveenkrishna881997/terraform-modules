#--------------
# Create a VPC
#--------------

resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(
    { "Name" = var.name
      "project" = var.vpc_tags
	}
  )
}

#-------------------------------
# Create an IGW for your new VPC
#-------------------------------
resource "aws_internet_gateway" "my_igw" {
  count = length(var.public_subnets) > 0 ? 1 : 0 # According to this expression first value is true and the second value is False. 0 is false and 1(anything greater than 0) is true.This expression is called Ternary operator
  vpc_id = aws_vpc.my_vpc.id # implecit dependency (Interpolation- resourcetype.resourcename.attribute)

  tags = merge(
    { "Name" = var.name
      "project" = var.igw_tags
	}
  )
}

# --------------------------------------------------------
# GET THE LIST OF AVAILABILITY ZONES IN THE CURRENT REGION
# --------------------------------------------------------
data "aws_availability_zones" "all" {}

#-----------------------
# Create a Public subnet 
#-----------------------
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets)
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = data.aws_availability_zones.all.names[count.index]

  tags = merge(
    { "Name" = var.name
      "project" = var.public_subnet_tags
	}
  )
  
}

#----------------------------------
# Create an RouteTable for your VPC
#----------------------------------
resource "aws_route_table" "public" {
    count = length(var.public_subnets) > 0 ? 1 : 0 # Ternary operator
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "DEMO Public RouteTable - NAVEENKRISHNA"
    }
}

#----------------------------------------
# Associate the RouteTable to the Subnets 
#----------------------------------------
resource "aws_route_table_association" "public" {
    count = length(var.public_subnets)
    subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
    #for_each = toset(var.public_subnets)
    #subnet_id =  each.value
    route_table_id = aws_route_table.public[0].id
}

#----------------------------------
# Add route entry(Internet traffic) to the RouteTable
#----------------------------------
resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw[0].id

  timeouts {
    create = "5m"
  }
}

#--------------------------
# CREATE THE SECURITY GROUP 
#--------------------------
resource "aws_security_group" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.my_vpc.id


  # Allow all outbound 
   dynamic "egress" {
        for_each = var.sg_public_egress
        content {
            from_port   = egress.value
            to_port     = egress.value
            protocol    = "tcp"
            cidr_blocks = [ "0.0.0.0/0" ]
        }
    }

  # Inbound for SSH
   dynamic "ingress" {
    for_each = var.sg_public_ingress
    content {
      cidr_blocks = [ "0.0.0.0/0" ]
      description      = ingress.value["description"]
      from_port        = ingress.value["port"]
      to_port          = ingress.value["port"]
      protocol         = ingress.value["protocol"]
    }
  }
  
}

#----------------------------------
# Create a Private subnet
#----------------------------------
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets)
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = element(var.private_subnets, count.index)
  availability_zone = data.aws_availability_zones.all.names[count.index]

  tags = merge(
    { "Name" = var.name
      "project" = var.private_subnet_tags
        }
  )
}

#----------------------------------
# Create an RouteTable for Private subnet
#----------------------------------
resource "aws_route_table" "private" {
    count = length(var.private_subnets) > 0 ? 1 : 0
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "DEMO private RouteTable - NAVEENKRISHNA"
    }
}

#----------------------------------------
# Associate the RouteTable to Private Subnets
#----------------------------------------
resource "aws_route_table_association" "private" {
    count = length(var.private_subnets)
    subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
    route_table_id = aws_route_table.private[0].id
}

#--------------------------
# CREATE THE SECURITY GROUP FOR PRIVATE
#--------------------------
resource "aws_security_group" "private" {
  count = length(var.private_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.my_vpc.id


  # Allow all outbound
   dynamic "egress" {
        for_each = var.sg_private_egress
        content {
            from_port   = egress.value
            to_port     = egress.value
            protocol    = "tcp"
            cidr_blocks = [ "0.0.0.0/0" ]
        }
    }
}

#--------------------------
# CREATE THE INGRESS RULES
#--------------------------
resource "aws_security_group_rule" "private" {
   count = length(var.sg_private_ingress) > 0 ? 1 : 0
   type              = "ingress"
   from_port         = var.sg_private_ingress[count.index]
   to_port           = var.sg_private_ingress[count.index]
   protocol          = "tcp"
   security_group_id = aws_security_group.private[0].id
   cidr_blocks = [ "0.0.0.0/0" ]
}


locals {                  # Expression       True value                False value
  nat_gateway_ips   = var.reuse_nat_ips ? var.external_nat_ip_ids : try(aws_eip.nat[*].id, [])
}

#--------------------------
# CREATE EIP FOR NAT GATEWAY
#--------------------------
resource "aws_eip" "nat" {
  count =  var.enable_nat_gateway && length(var.public_subnets) > 0 ? 1 : 0
  domain = "vpc"

  depends_on = [aws_internet_gateway.my_igw]
}

#-------------------
# CREATE NAT GATEWAY
#-------------------
resource "aws_nat_gateway" "public" {
  count =  var.enable_nat_gateway && length(var.public_subnets) > 0 ? 1 : 0
  allocation_id = element(local.nat_gateway_ips, count.index)
  subnet_id = aws_subnet.public_subnet[0].id

  depends_on = [aws_internet_gateway.my_igw]
}

#-------------------------
# MAP ROUTE FOR NAT GATEWAY
#--------------------------
resource "aws_route" "private_nat_gateway" {
  count =  var.enable_nat_gateway && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id              = aws_route_table.private[0].id
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id              = aws_nat_gateway.public[0].id

  timeouts {
    create = "5m"
  }
}
