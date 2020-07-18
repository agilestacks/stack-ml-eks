# ML Stack on EKS

ML Stack is designed to simplify the deployment of machine learning projects like Kubeflow on AWS EKS.  It supports the full lifecycle of an ML application and automates deployment of the following tools and frameworks: Kubeflow, Tensorflow, Pytorch, XGBoost, Jupyter Notebook, TensorBoard, Seldon, Minio, Spark, Amazon SageMaker.

## Installation

A new EKS cluster can be created using the [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) tool and the provided configuration file: [etc/eks-cluster.yaml](etc/eks-cluster.yaml). If you already have an existing EKS cluster, please make sure that following addons are deployed: `certManager` and `externalDNS`.

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

2. Configure prerequisites

```bash
$ hub configure --current-kubecontext
```

This command will your current kubeconfig context (defined by `eksctl`), generate the necessary configuration and store it in environment file (`.env` points to current active configuration)

* Generate a unique domain name (valid for 24 hours unless refreshed with `hub configure` command)
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
$ eksctl delete cluster -f etc/eks-cluster.yaml
```

Or otherwise this command when name derived has been reconfigured by variable `STACK_NAME`

```bash
$ eksctl delete cluster --name="$STACK_NAME"
```
