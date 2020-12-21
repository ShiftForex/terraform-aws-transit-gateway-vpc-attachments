variable "name" {}

variable "create_vpc_route" {
  description = "Create VPC route in all VPC route tables"
  type        = bool
  default     = true
}

variable "destination_cidr_block" {
  description = "CIDR of the VPC being attached to Transit Gateway."
  type        = string
  default     = null
}

variable "route_table_association_id" {
  description = "Route table id to associate with Transit Gateway attachmnent"
  type        = string
  default     = null
}

variable "route_table_create" {
  description = "Bool whether to create a transit gateway route table"
  type        = bool
  default     = true
}

variable "route_table_id" {
  description = "Route Table Id for attached VPC route to get propagated to."
  type        = string
  default     = null
}

variable "route_table_propagation_ids" {
  description = "Route table IDs to propagate transit gateway attachments to."
  type        = list(string)
  default     = null
}

variable "subnet_id_filters" {
  description = "Subnet Ids of VPC to attach."
  default     = [{
    name   = "tag:Name"
    values = ["*private*"]
  }]
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = null
}

variable "transit_gateway_default_route_table_association" {
  description = "Bool whether to attachment is associated with default transit gateway."
  type        = bool
  default     = false
}

variable "transit_gateway_id" {
  description = "Transit Gateway Id to attach VPC to."
  type        = string
}

variable "transit_gateway_default_route_table_propagation" {
  description = "Bool whether to attachment is associated with default transit gateway."
  type        = bool
  default     = false
}

variable "vpc_filters" {
  description = "Filters to query VPCs to attach to transit gateway"
  default     = null
}

variable "vpc_ids" {
  description = "VPC ids to attach to transit gateway"
  type        = list(string)
  default     = null
}

variable "vpc_destination_cidrs" {
  description = "VPC CIDRS of the destination VPCs"
  type        = set(string)
  default     = []
}
