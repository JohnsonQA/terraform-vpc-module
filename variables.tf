variable cidr_block{
    default = "10.0.0.0/16"     // Allocating 16 bits to Network using CIDR. 
}

variable "project"{
    type = string
}

variable "environment"{
    type = string
}

variable "public_subnet_cidrs"{
    type = list(string)
}