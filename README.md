# ML Stack for EKS

Certified tack for Kubeflow at AWS EKS cluster

## Installation

It has been advised that EKS cluster has been created from the configuration file described (etc/eks-cluster.yaml)[etc/eks-cluster.yaml]. If you have existing EKS cluster please make sure that following addons has been activated: `certManager` and `externalDNS`.

1. Create an EKS cluster.

```bash
$ eksctl create cluster -f etc/eks-cluster.yaml
```

Or create cluster with different name
```bash
$ export STACK_NAME="better-name-for-my-cluster"
$ cat etc/eks-cluster.yaml \
  | sed -e "s/happy-cluster/$STACK_NAME/g" \
  | eksctl create cluster -f -
```

## Tear Down

If you have used a default name to setup your cluster then please use command below:

```bash
$ eksctl delete cluster -f etc/eks-cluster.yaml
```   
Or otherwise this command when name derived has been reconfigured by variable `STACK_NAME` 

```bash
$ eksctl delete cluster --name="$STACK_NAME"
```
