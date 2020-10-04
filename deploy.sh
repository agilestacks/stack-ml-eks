#!/usr/bin/env bash
# Example script to deploy a custom stack from Git
mkdir -p mystack
cd mystack
# Download config file for EKS cluster
wget https://raw.githubusercontent.com/agilestacks/stack-ml-eks/master/etc/eks-cluster.yaml
# Set EKS cluster name
export STACK_NAME="kf1"
# Create EKS cluster in the current AWS account
cat eks-cluster.yaml | sed -e "s/happy-cluster/$STACK_NAME/g" | eksctl create cluster -f -
# Configure environment for deploying Kubeflow stack and download all required files to the current directory
hub configure -f "https://raw.githubusercontent.com/agilestacks/stack-ml-eks/master/hub.yaml"
# Deploy Kubeflow stack to the EKS cluster
hub stack deploy
# Optional undeploy step - uncomment the following line to delete EKS cluster and cleanup AWS resources
# cat eks-cluster.yaml | sed -e "s/happy-cluster/$STACK_NAME/g" | eksctl delete cluster -f -