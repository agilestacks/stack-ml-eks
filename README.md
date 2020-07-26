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

By default, the cluster is provisioned with a minimum set of permissions required to run the majority of the pods.  If you need to add more permissions for the cluster, you can attach additional IAM policies.  Use the following command as an example for adding standard IAM policies to your cluster:

```
$ hub ext eks attach policy \
  --cluster "$STACK_NAME" \
  --policy "AmazonS3FullAccess"
```

3. Configure prerequisites

```bash
$ hub configure --current-kubecontext --force
```

This command will use your current kubeconfig context (defined by `eksctl`), generate the necessary configuration and store it in an environment file (`.env` points to current active configuration)

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

## Access the Kubeflow user interface (UI)
After the stacks is deployed, the Kubeflow Dashboard can be accessed via istio-ingressgateway service.  You can find the URL of deployed gateway using `kubectl` command:
```bash
$ kubectl get gateways --all-namespaces -o yaml
```
The URL for Kubeflow dashboard is shown in the `hosts` section for the following Istio gateway: 
`name: kubeflow-gateway`
To confirm the ingress gateway is serving the application to the load balancer, use:
```bash
$ curl http://kubeflow.example.devops.delivery:80/
```

## Additional Options

### Redeploy one or more components

Redeploy one or more compomnents. The following commands will redeploy two stack components: `istio` and `prometheus`

```bash
$ hub ext stack undeploy -c istio,prometheus
$ hub ext stack deploy -c istio,prometheus
```

### Deploy all components starting from the pre-deployed component

Deploy the specified component and all subsequent components in the stack runlist.

```bash
$ hub ext stack deploy -o istio
```

## Tear Down

If you have used a default name to setup your cluster then you can use the following command to undeploy the entire stack:

```bash
$ hub ext stack undeploy
$ hub ext eks detach policy --cluster $STACK_NAME --all
$ eksctl delete cluster -f etc/eks-cluster.yaml
```

Otherwise, use the following command if the stack name was configured with variable `STACK_NAME`:

```bash
$ eksctl delete cluster --name="$STACK_NAME"
```
