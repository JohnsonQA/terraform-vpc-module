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
        local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    }
    )
}



