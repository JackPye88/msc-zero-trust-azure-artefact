locals {
  KeyVault = {
    for name, kv in var.key_vaults : name => merge(kv, {
      primary_ip   = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), kv.ip_offset)
      secondary_ip = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), kv.ip_offset)
      ip_rules     = kv.ip_rules
    })
  }

  automation_account = {
    for name, aa in var.automation_accounts : name => merge(aa, {
      primary_ip_1   = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), aa.ip_offset_1)
      primary_ip_2   = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), aa.ip_offset_2)
      secondary_ip_1 = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), aa.ip_offset_1)
      secondary_ip_2 = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), aa.ip_offset_2)
    })
  }

  disk_encryption_set = var.disk_encryption_sets

  recovery_services_vault = {
    for name, rsv in var.recovery_services_vaults : name => merge(rsv, {
      primary_ip_1   = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), rsv.ip_offsets[0])
      primary_ip_2   = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), rsv.ip_offsets[1])
      primary_ip_3   = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), rsv.ip_offsets[2])
      primary_ip_4   = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), rsv.ip_offsets[3])
      primary_ip_5   = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), rsv.ip_offsets[4])
      secondary_ip_1 = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), rsv.ip_offsets[0])
      secondary_ip_2 = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), rsv.ip_offsets[1])
      secondary_ip_3 = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), rsv.ip_offsets[2])
      secondary_ip_4 = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), rsv.ip_offsets[3])
      secondary_ip_5 = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), rsv.ip_offsets[4])
    })
  }

  asr_cache = {
    for name, asr in var.asr_caches : name => merge(asr, {
      primary_ip   = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), asr.ip_offset)
      secondary_ip = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), asr.ip_offset)
    })
  }

  shared_storage = {
    for name, ss in var.shared_storage_accounts : name => merge(ss, {
      primary_ip   = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ss.ip_offset)
      secondary_ip = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ss.ip_offset)
    })
  }

  virtual_machines = {
    for name, vm in var.virtual_machines : name => merge(vm, {
      ip_address_primary   = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 2), vm.ip_offset)
      ip_address_secondary = vm.deploy_secondary ? cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 2), vm.ip_offset) : ""
    })
  }

  application_insights = {
    for name, ai in var.application_insights : name => merge(ai, {
      primary_ip_1  = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[0])
      primary_ip_2  = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[1])
      primary_ip_3  = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[2])
      primary_ip_4  = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[3])
      primary_ip_5  = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[4])
      primary_ip_6  = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[5])
      primary_ip_7  = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[6])
      primary_ip_8  = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[7])
      primary_ip_9  = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[8])
      primary_ip_10 = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[9])
      primary_ip_11 = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[10])
      primary_ip_12 = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[11])
      primary_ip_13 = cidrhost(cidrsubnet(var.primary_network_address, var.subnet_prefix_bits, 1), ai.primary_offsets[12])

      secondary_ip_1  = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ai.secondary_offsets[0])
      secondary_ip_2  = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ai.secondary_offsets[1])
      secondary_ip_3  = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ai.secondary_offsets[2])
      secondary_ip_4  = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ai.secondary_offsets[3])
      secondary_ip_5  = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ai.secondary_offsets[4])
      secondary_ip_6  = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ai.secondary_offsets[5])
      secondary_ip_7  = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ai.secondary_offsets[6])
      secondary_ip_8  = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ai.secondary_offsets[7])
      secondary_ip_9  = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ai.secondary_offsets[8])
      secondary_ip_10 = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ai.secondary_offsets[9])
      secondary_ip_11 = cidrhost(cidrsubnet(var.secondary_network_address, var.subnet_prefix_bits, 1), ai.secondary_offsets[10])
    })
  }
}