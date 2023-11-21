---
- name: InternalApi
  name_lower: internal_api
  vip: true
  mtu: 1500
  subnets:
    internal_api_subnet:
      ip_subnet: 192.168.31.0/24
      allocation_pools:
        - start: 192.168.31.100
          end: 192.168.31.200
      vlan: 31
- name: Tenant
  vip: false # Tenant network does not use VIPs
  mtu: 1500
  name_lower: tenant
  subnets:
    tenant_subnet:
      ip_subnet: 192.168.32.0/24
      allocation_pools:
        - start: 192.168.32.100
          end: 192.168.32.200
      vlan: 32
- name: Storage
  name_lower: storage
  vip: true
  mtu: 1500
  subnets:
    storage_subnet:
      ip_subnet: 192.168.33.0/24
      allocation_pools:
        - start: 192.168.33.100
          end: 192.168.33.200
      vlan: 33
- name: StorageMgmt
  name_lower: storage_mgmt
  vip: true
  mtu: 1500
  subnets:
    storage_mgmt_subnet:
      ip_subnet: 192.168.34.0/24
      allocation_pools:
        - start: 192.168.34.100
          end: 192.168.34.200
      vlan: 34
- name: External
  name_lower: external
  vip: true
  mtu: 9000
  subnets:
    external_subnet:
      ip_subnet: 192.168.35.0/24
      allocation_pools:
        - start: 192.168.35.100
          end: 192.168.35.200
      vlan: 35
      gateway_ip: "192.168.35.1"
