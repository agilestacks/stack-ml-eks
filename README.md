# ML Stack on EKS

ML Stack is designed to simplify the deployment of [Kubeflow](https://github.com/kubeflow) and additional components on AWS EKS.  It supports the full lifecycle of machine learning projects: data preparation, model development, training, serving, and monitoring.

## Installation

A new EKS cluster can be created using the [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) tool and the configuration file [etc/eks-cluster.yaml](etc/eks-cluster.yaml). If you already have an existing EKS cluster, please make sure that following addons are deployed: `certManager` and `externalDNS`.

1. Create an EKS cluster

```bash
$ eksctl create cluster -f etc/eks-cluster.yaml
```

Or create cluster with a different name

```bash
$ export STACK_NAME="better-name-for-my-cluster"
$ cat etc/eks-cluster.yaml \
  | sed -e "s/happy-cluster/$STACK_NAME/g" \
  | eksctl create cluster -f -
```

2. Attach sufficient IAM policies

By default cluster has been provisioned with minimum viable rights to run majority of the pods. However if you are willing to add extra rights to allow pods in your cluster to add some resources then you might want to run following command. Please consider it as an example

```
$ hub ext eks attach policy \
  --cluster "$STACK_NAME" \
  --policy "AmazonS3FullAccess"
```

3. Configure prerequisites

```bash
$ hub configure --current-kubecontext
```

This command will your current kubeconfig context (defined by `eksctl`), generate the necessary configuration and store it in environment file (`.env` points to current active configuration)

* Generate a unique domain name (valid for 24 hours unless refreshed with `hub configure` command)
* Domain name refresh key. A token that authorizes domain name refresh
* Definition of AWS configuration (s3 bucket to store deployment state)

4. Install prerequisites (one time operation)

Before you deploy a cluster, we need to be sure that prerequisites defined in configure steps are met

```bash
$ hub ext aws status
$ hub ext aws init
```

5. Deploy current stack

```bash
$ hub ext stack deploy
```

## What else I can do

### Redeploy one or more components

Redeploy one or more compomnents. The following commands will redeploy two stack components: `istio` and `prometheus`

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
$ hub ext eks detach policy --cluster $STACK_NAME --all
$ eksctl delete cluster -f etc/eks-cluster.yaml
```

Or otherwise this command when name derived has been reconfigured by variable `STACK_NAME`

```bash
$ eksctl delete cluster --name="$STACK_NAME"
```
