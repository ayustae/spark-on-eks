#!/bin/bash

# Connect to the EKS cluster
/etc/eks/bootstrap.sh \
    --container-runtime containerd \
    --aws-api-retry-attempts 1 \
    ${eks_cluster_name}

# Update the system
yum upgrade -y

