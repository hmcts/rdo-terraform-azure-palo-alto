# About

This is designed to be used as a module.

It creates a scalable palo alto configuration in an azure availability set.

# Howto
Call the module with the variables specified in 01-inputs-required.tf
The module outputs a variable with the ip address of the loadbalancer

A UDR added to the subnets is required to force the traffic through the
loadbalancer ip address - hitting the palo alto firewalls.

A single nic firewall guarantees that the return traffic will go via the same
firewall:
https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-ha-ports-overview

# Diagram
                                      +------------------+
    +--------+                        | Subnet-A         |
    |        |                        |                  |
    |  Palo  |       +-------+  +-------+ UDR            |
    |        +<------+       |  v     +------------------+
    +--------+       | Azure |  LB
                     |  LB   |  IP
    +--------+       |       |  ^     +------------------+
    |        +<------+       |  +--------+UDR            |
    |  Palo  |       +-------+        |                  |
    |        |                        | Subnet-B         |
    +--------+                        +------------------+
