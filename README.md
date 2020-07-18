# ML Stack for EKS

Certified tack for Kubeflow at AWS EKS cluster

## Installation

It has been advised that EKS cluster has been created from the configuration file described [etc/eks-cluster.yaml](etc/eks-cluster.yaml). If you    have existing EKS cluster please make sure that following addons has been activated: `certManager` and `externalDNS`.

1. Create an EKS cluster

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

2. Setup prerequisites

```bash
$ hub configure --current-kubecontext
```

This command will benefit from current context in your kubeconfig (defined by `eksctl`) and generate necessary configuration and store in environment file (`.env` points to current active configuration)

* Generate a unique domain name (valid for 24hours unless refreshed)
* Domain name refresh key. A token that authorizes domain name refresh
* Definition of AWS configuration (s3 bucket to store deployment state)

3. Install prerequisites (one time operation)

Before you deploy a cluster, we need to be sure that prerequisites defined in configure steps are met

```bash
$ hub ext aws status
$ hub ext aws init
```

4. Deploy current stack

```bash
$ hub ext stack deploy
```

## What else I can do

### Redeploy one or fiew components

Redeoloy one or few compomnents. Command below will redeploy two components of a stack `istio` and `prometheus`

```bash
$ hub ext stack undeploy -c istio,prometheus
$ hub ext stack deploy -c istio,prometheus
```


### Deploy all components from...

Deploy specified component and all following components in the runlist

```bash
$ hub ext stack deploy -o istio
```

## Tear Down

If you have used a default name to setup your cluster then please use command below:

```bash
$ hub ext stack undeploy
$ eksctl delete cluster -f etc/eks-cluster.yaml
```

Or otherwise this command when name derived has been reconfigured by variable `STACK_NAME`

```bash
$ eksctl delete cluster --name="$STACK_NAME"
```
