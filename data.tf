#Using data source we can get the output from provider
data "aws_availability_zones" "az_info"{
    state = "available"
}

/* output "az_name"{
    value = data.aws_availability_zones.az_info
} */