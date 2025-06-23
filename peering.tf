#My VPC peering with default VPC
# To establish a connection, need to get the default vpc id and my vpc ID
resource "aws_vpc_peering_connection" "default"{
count = var.is_peering_required ? 1 : 0   //1 means true and 0 means false

peer_vpc_id = data.aws_vpc.default.id  #it's acceptor VPC i.e. default here
vpc_id = aws_vpc.main.id               #It's requestor VPC (my vpc) id

accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

auto_accept = true   #when two vpc are in same account and region it auto accept the request
 tags = merge(
    var.vpc_peering_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-default"
    }
  )

}

#Now route the required subnets to the default VPC
resource "aws_route" "public_peering"{
    count = var.is_peering_required ? 1 : 0
    route_table_id = aws_route_table.public.id
    destination_cidr_block = data.aws_vpc.default.cidr_block #Default vpc cidr block 
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id  #It usually gives a list.Though its a only one ID we need to pass it as list
}

resource "aws_route" "private_peering"{
    count = var.is_peering_required ? 1 : 0
    route_table_id = aws_route_table.private.id
    destination_cidr_block = data.aws_vpc.default.cidr_block #Default vpc cidr block 
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id  #It usually gives a list.Though its a only one ID we need to pass it as list
}

resource "aws_route" "database_peering"{
    count = var.is_peering_required ? 1 : 0
    route_table_id = aws_route_table.database.id
    destination_cidr_block = data.aws_vpc.default.cidr_block #Default vpc cidr block 
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id  #It usually gives a list.Though its a only one ID we need to pass it as list
}

#Should add peering connection from default to my vpc 
resource "aws_route" "default_peering"{
    count = var.is_peering_required ? 1 : 0
    route_table_id = data.aws_route_table.main.id
    destination_cidr_block = var.cidr_block   #it's my vpc cider block
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
} 