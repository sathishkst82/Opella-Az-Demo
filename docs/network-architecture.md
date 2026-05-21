# Network Architecture

CIDR allocation:

| Environment | VNET CIDR |
| --- | --- |
| DEV | `10.10.0.0/16` |
| UAT | `10.15.0.0/16` |
| PROD | `10.20.0.0/16` |

Subnet layout:

| Subnet | Purpose | DEV | UAT | PROD |
| --- | --- | --- | --- | --- |
| management-subnet | Jump, management, platform tools | `10.10.0.0/24` | `10.15.0.0/24` | `10.20.0.0/24` |
| application-subnet | App and orchestration workloads | `10.10.10.0/24` | `10.15.10.0/24` | `10.20.10.0/24` |
| data-subnet | Data services and storage integration | `10.10.20.0/24` | `10.15.20.0/24` | `10.20.20.0/24` |
| private-endpoint-subnet | Private Link endpoints | `10.10.30.0/24` | `10.15.30.0/24` | `10.20.30.0/24` |
| future-reserved-subnet | Growth buffer | `10.10.250.0/24` | `10.15.250.0/24` | `10.20.250.0/24` |

The `/16` per environment prevents overlap and leaves space for additional `/24` segments, AKS node pools, firewall subnets, Bastion, VPN Gateway, and hub-spoke peering. The third octet is purpose-based, making routes and firewall rules easy to reason about across environments.

Hybrid readiness is preserved through private RFC1918 ranges, route table hooks, optional custom DNS servers, and a private endpoint subnet. Peering readiness comes from non-overlapping environment ranges and stable subnet segmentation.
