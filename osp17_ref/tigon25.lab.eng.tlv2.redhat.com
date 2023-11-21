{
  "nodes": [
    {
      "mac": ["6c:fe:54:3f:87:00"],
      "name": "compute-0",
      "cpu": "40",
      "memory": "125000",
      "disk": "100",
      "arch": "x86_64",
      "pm_type": "pxe_ipmitool",
      "pm_user": "root",
      "pm_password": "calvin",
      "pm_addr": "tigon23-bmc.mgmt.lab.eng.tlv2.redhat.com",
      "root_device": {
        "wwn_with_extension": "0x6ec2a72046f72f002b65936fbccfe6d7"
      }
    },
    {
      "mac": ["6c:fe:54:3f:b4:90"],
      "name": "compute-1",
      "cpu": "40",
      "memory": "125000",
      "disk": "100",
      "arch": "x86_64",
      "pm_type": "pxe_ipmitool",
      "pm_user": "root",
      "pm_password": "calvin",
      "pm_addr": "tigon24-bmc.mgmt.lab.eng.tlv2.redhat.com",
      "root_device": {
        "wwn_with_extension": "0x6ec2a72046f746002b659a0cbb08577e"
      }
    }
  ]
}
