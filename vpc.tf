//Creating VPC module as an util to re-use this in projects
// aws_vpc is Resourec_ResourceType and main is a local name which we can used to refer this vpc  in project. It can be any name
//Ex: my_vpc or this anything. Ex in your code - aws_vpc.main.id
//Detail expalnation in One Notes session 36 section "terraform code Explanation"
//it enables dns hosts to configure domains
//roboshop-vpc-dev

resource "aws_vpc" "main" {
    cidr_block = var.cidr_block
    instance_tenancy = "default"
    enable_dns_hostnames = "true"     

    tags = merge(
        var.vpc_tags,                 //If user provides vpc_tags it will add here, if not it's an empty and optional {}
        local.common_tags,
        {
            Name = "${var.project}-vpc-${var.environment}"
        }
    )
}

#Associate IGW to VPC
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id   #It will associate the vpc id to IGW  

    tags = merge(
        var.igw_tags,
        local.common_tags,
        {
            Name = "${var.project}-igw-${var.environment}"
        }
    )
}

#Need subnet name as roboshop-dev-us-east-1a
resource "aws_subnet" "public"{
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]    #since we need 2 pub subnets, we using count based loop
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true   #for public subnets it will automaticall give access to internet when ec2 is alunched in pub subnets

    tags = merge(
        var.public_tags,
        local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    }
    )
}

resource "aws_subnet" "private"{
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]    #since we need 2 priv subnets, we using count based loop
    availability_zone = local.az_names[count.index]

    tags = merge(
        var.private_tags,
        local.common_tags,
    {
        Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
    }
    )
}

resource "aws_subnet" "database"{
    count = length(var.database_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[count.index]    #since we need 2 pub subnets, we using count based loop
    availability_zone = local.az_names[count.index]

    tags = merge(
        var.database_tags,
        local.common_tags,
    {
        Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
    }
    )
}

# EIP will create a static ip which can be used for NGW. so that IP won't change of NGW and traffic can route seamleslly
resource "aws_eip" "nat"{
    domain = "vpc"
    tags = merge(
    var.eip_tags,
    local.common_tags,
    {
      Name = "${var.project}-eip-${var.environment}"
    }
  )
}

resource "aws_nat_gateway" "main"{
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public[0].id        //us-east-1a id will take as we mostly use this so we are configuring this

    tags = merge(
    var.ngw_tags,
    local.common_tags,
    {
      Name = "${var.project}-ngw-${var.environment}"
    }
  ) 
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]   
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.public_route_table_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_route_table_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-private"
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.database_route_table_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-database"
    }
  )
}

//routes to public, private and internet and vice versa
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

//Routetable association with subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}