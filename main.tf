data "aws_vpc" "service" {
  for_each = local.vpc_ids

  id = each.value
}

data "aws_vpcs" "vpcs" {
  count = var.vpc_ids == null ? 1 : 0

  dynamic "filter" {
    for_each = local.vpc_filters
    content {
      name = filter.value["name"]
      values = filter.value["values"]
    }
  }
}

data "aws_subnet_ids" "service" {
  for_each = local.vpc_ids

  dynamic "filter" {
    for_each = var.subnet_id_filters
    content {
      name = filter.value["name"]
      values = filter.value["values"]
    }
  }

  vpc_id = each.value
}

data "aws_route_tables" "service" {
  for_each = local.vpc_ids

  vpc_id = each.value
}

locals {
  route_table_propagation_attachment_map = var.route_table_propagation_ids != null ? flatten([
      for vpc, attachment in aws_ec2_transit_gateway_vpc_attachment.service : [
        for route_table_id in var.route_table_propagation_ids : {
          attachment_id = attachment.id
          route_table_id = route_table_id
        }
      ]
    ]
  ) : []
  route_table_id = var.route_table_id == null && var.route_table_create == true ? aws_ec2_transit_gateway_route_table.service[0].id : var.route_table_id
  tags = var.tags == null ? {
    Name = "${var.name}-vpc"
    env  = terraform.workspace
  } : var.tags
  vpc_filters = var.vpc_filters == null ? [{
    name   = "tag:env"
    values = [terraform.workspace]
  }] : var.vpc_filters
  vpc_ids = var.vpc_ids == null ? data.aws_vpcs.vpcs[0].ids : toset(var.vpc_ids)
  vpc_route_tables_map = flatten([
    for vpc, route_tables in data.aws_route_tables.service : [
      for route_table_id in route_tables.ids : [
        for destination_cidr in var.vpc_destination_cidrs : {
          destination_cidr = destination_cidr
          route_table_id = route_table_id
        }
      ]
    ]
  ])
}

resource "aws_ec2_transit_gateway_vpc_attachment" "service" {
  for_each = local.vpc_ids

  subnet_ids                                      = data.aws_subnet_ids.service[each.value].ids
  transit_gateway_id                              = var.transit_gateway_id
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation
  vpc_id                                          = each.value

  tags = merge(local.tags, {Name = data.aws_vpc.service[each.value].tags["Name"]})
}

resource "aws_ec2_transit_gateway_route_table" "service" {
  count = var.route_table_create == true ? 1 : 0

  transit_gateway_id = var.transit_gateway_id

  tags = local.tags
}

resource "aws_ec2_transit_gateway_route_table_propagation" "service" {
  for_each = {
    for item in local.route_table_propagation_attachment_map : "${item.attachment_id}.${item.route_table_id}" => item
  }

  transit_gateway_attachment_id  = each.value.attachment_id
  transit_gateway_route_table_id = each.value.route_table_id
}

resource "aws_ec2_transit_gateway_route_table_association" "service" {
  for_each = var.route_table_association_id == null ? [] : local.vpc_ids

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.service[each.value].id
  transit_gateway_route_table_id = var.route_table_association_id
}

resource "aws_route" "service" {
  for_each = {
    for item in local.vpc_route_tables_map : "${item.destination_cidr}.${item.route_table_id}" => item
  }

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr
  transit_gateway_id     = var.transit_gateway_id

  timeouts {
    create = "5m"
  }
}
