{
  "nodes": [
    {
      "mac": ["6c:fe:54:3f:a2:10"],
      "name": "compute-0",
      "cpu": "40",
      "memory": "125000",
      "disk": "100",
      "arch": "x86_64",
      "pm_type": "pxe_ipmitool",
      "pm_user": "root",
      "pm_password": "calvin",
      "pm_addr": "tigon26-bmc.mgmt.lab.eng.tlv2.redhat.com",
      "root_device": {
        "wwn_with_extension": "0x6ec2a72046fb9b002b65a08abceccb22"
       }
    },

    {
      "mac": ["6c:fe:54:3f:ac:f0"],
      "name": "compute-1",
      "cpu": "40",
      "memory": "125000",
      "disk": "100",
      "arch": "x86_64",
      "pm_type": "pxe_ipmitool",
      "pm_user": "root",
      "pm_password": "calvin",
      "pm_addr": "tigon27-bmc.mgmt.lab.eng.tlv2.redhat.com",
      "root_device": {
        "wwn_with_extension": "0x6ec2a72046fa74002b65a39cbd29fe1c"
       }
    }
  ]
}
