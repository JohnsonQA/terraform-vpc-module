#Using data source we can get the output from provider
data "aws_availability_zones" "az_info"{
    state = "available"
}

/* output "az_name"{
    value = data.aws_availability_zones.az_info
} */

# It's used to get the default VPC details
data "aws_vpc" "default" {
    default = true
}

data "aws_route_table" "main"{
    vpc_id = data.aws_vpc.default.id            #It will give the list of vpc details like routes, routetables and so on..from there we will get the routetable ID
    filter {
    name = "association.main"    #If true it will associate with default vpc route table 
    values = ["true"]
  }
}