locals {
    common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }

    az_names = slice(data.aws_availability_zones.az_info.names, 0, 2)
}