#!/bin/bash

# Update the system
yum update -y

# Connect to the EKS cluster
/etc/eks/bootstrap.sh i\
    --container-runtaime containerd \
    --aws-api-retry-attempts 5 \
    ${eks_cluster_name}
