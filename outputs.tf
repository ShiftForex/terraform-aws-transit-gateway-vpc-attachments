output "aws_ecs_transit_gateway_vpc_attachment" {
  value = aws_ec2_transit_gateway_vpc_attachment.service
}

output "vpc" {
  value = data.aws_vpc.service
}

output "vpcs" {
  value = data.aws_vpcs.vpcs
}

output "vpc_route_tables" {
  value = data.aws_route_tables.service
}

output "vpc_route_tables_map" {
  value = local.vpc_route_tables_map
}

output "route_table_id" {
  value = local.route_table_id
}

output "subnet_ids" {
  value = data.aws_subnet_ids.service
}

output "vpc_ids" {
  value = local.vpc_ids
}
