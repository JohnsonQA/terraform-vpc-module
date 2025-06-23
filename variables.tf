variable cidr_block{
    default = "10.0.0.0/16"     // Allocating 16 bits to Network using CIDR. 
}

variable "project"{
    type = string
}

variable "environment"{
    type = string
}

#we give specific tags to every resource as best practi8ces and readability
variable "vpc_tags"{
    type = map(string)
    default = {}        //if given default it is not mandatory and user can override their own tags     
}

variable "igw_tags"{
    type = map(string)
    default = {}        //if given default it is not mandatory and user can override their own tags     
}

variable "public_subnet_cidrs"{
    type = list(string)
}

variable "public_tags"{
    type = map(string)
    default = {}        //if given default it is not mandatory and user can override their own tags     
}

variable "private_subnet_cidrs"{
    type = list(string)
}

variable "private_tags"{
    type = map(string)
    default = {}        //if given default it is not mandatory and user can override their own tags     
}

variable "database_subnet_cidrs"{
    type = list(string)
}

variable "database_tags"{
    type = map(string)
    default = {}        //if given default it is not mandatory and user can override their own tags     
}

variable "eip_tags"{
    type = map(string)
    default = {}
}

variable "ngw_tags"{
    type = map(string)
    default = {}
}

variable "public_route_table_tags" {
    type = map(string)
    default = {}
}

variable "private_route_table_tags" {
    type = map(string)
    default = {}
}

variable "database_route_table_tags" {
    type = map(string)
    default = {}
}

variable "is_peering_required"{
    default = false
}

variable "vpc_peering_tags" {
    type = map(string)
    default = {}
}