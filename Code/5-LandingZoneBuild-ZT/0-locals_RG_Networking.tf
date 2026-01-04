locals {
  lz_spoke_subnets = {
    for name, subnet in var.lz_spoke_subnets : name => merge(subnet, {
      subnet_address_primary   = cidrsubnet(var.primary_network_address, subnet.subnet_prefix_bits, subnet.subnet_index)
      subnet_address_secondary = cidrsubnet(var.secondary_network_address, subnet.subnet_prefix_bits, subnet.subnet_index)
    })
  }
}
