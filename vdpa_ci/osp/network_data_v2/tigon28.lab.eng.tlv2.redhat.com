---
- name: InternalApi
  name_lower: internal_api
  vip: true
  vlan: 51
  ip_subnet: "192.168.51.0/24"
  allocation_pools:
    - start: "192.168.51.100"
      end: "192.168.51.200"
- name: Tenant
  vip: false # Tenant network does not use VIPs
  name_lower: tenant
  vlan: 52
  ip_subnet: "192.168.52.0/24"
  allocation_pools:
    - start: "192.168.52.100"
      end: "192.168.52.200"
- name: Storage
  name_lower: storage
  vip: true
  vlan: 53
  ip_subnet: "192.168.53.0/24"
  allocation_pools:
    - start: "192.168.53.100"
      end: "192.168.53.200"
- name: StorageMgmt
  name_lower: storage_mgmt
  vip: true
  vlan: 54
  ip_subnet: "192.168.54.0/24"
  allocation_pools:
    - start: "192.168.54.100"
      end: "192.168.54.200"
- name: External
  vip: true
  name_lower: external
  vlan: 55
  ip_subnet: "192.168.55.0/24"
  allocation_pools:
    - "start": "192.168.55.100"
      "end": "192.168.55.200"
