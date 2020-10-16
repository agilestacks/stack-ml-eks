# ML Stack on EKS

ML Stack is designed to simplify the deployment of [Kubeflow](https://github.com/kubeflow) and additional components on AWS EKS.  It supports the full lifecycle of machine learning projects: data preparation, model development, training, serving, and monitoring.  ML Stack is providing essential tools to improve productivity of data scientists, while making it easy for operations to deploy and scale machine learning applications in production.

## ML Stack Components

ML Stack provides an open-source machine learning platform that supports the full lifecycle of an ML application — from data preparation and model training to model deployment in production.  With Kubernetes under the hood, it’s a powerful toolset that can make Data Scientists and Data Engineers life easier.  ML Stacks is based on [Kubeflow](https://github.com/kubeflow) and additional components: external DNS, SSL certificate manager, Istio service mesh, S3 flex storage driver.
![Components](/etc/kubeflow_components.png)

## Installation

This repository provides a customizable GitOps stack template, which allows to deploy the entire Kubeflow platform with a few simple commands.  It allows to simplify, automate, and standardize Kubeflow deployments.  GitOps is defined as a way of managing cloud infrastructure and applications, using Git repository to hold declarative definition of infrastructure. You can use the following steps to deploy Kubeflow on an existing EKS cluster, or create a new EKS cluster for Kubeflow.

1. Intall Hub CLI

Hub CLI is an open source GitOps tool for automating deployment of customizable stacks created with Terraform, CloudFormation, Helm, and other infrastructure as code.
To install Hub CLI on your workstation please follow the steps documented [here](https://superhub.io)

2. Create an EKS cluster

If you have an existing EKS cluster, then use the following example command to configure EKS cluster context:
```bash
$ aws eks --region us-west-2 update-kubeconfig --name cluster-name
```

The following command will create a new EKS cluster with a custom name:

```bash
$ export STACK_NAME="my-cluster"
$ cat etc/eks-cluster.yaml | sed -e "s/happy-cluster/$STACK_NAME/g" | eksctl create cluster -f -
```

3. Attach sufficient IAM security policies

By default, the cluster is provisioned with a minimum set of permissions required to perform most common tasks.  If you need to add more AWS permissions for the cluster, you can attach additional IAM policies.  Use the following command as an example for adding standard IAM policies to your cluster:

```
$ hub ext eks policy attach \
  --cluster "$STACK_NAME" \
  --policy "AmazonS3FullAccess" \
  --aws-region us-west-2
  
```

4. Configure environment for deploying Kubeflow in the current directory:

```bash
$ hub configure -f https://raw.githubusercontent.com/agilestacks/stack-ml-eks/master/hub.yaml
```

This command will use your current kubeconfig context (defined by `eksctl`), generate the necessary configuration and store it in an environment file (`.env` points to current active configuration)

* Generate a unique domain name (valid for 72 hours unless refreshed with `hub configure` command)
* Domain name refresh key (a token that authorizes DNS domain name refresh)
* Definition of AWS configuration (S3 bucket to store deployment state)

The obtained DNS subdomain (of `bubble.superhub.io`) is valid for 72 hours. To renew the DNS lease, please re-run `hub configure -r aws --dns-update` every other day. Contact `support@agilestacks.com` for non-expiring DNS domain.

ML Stack will configure a user/password authentication. During `hub configure` step you will be asked to define a user name and password. Your password will be stored in `.env` file and should not be committed to the git repository. If you want to change the password later, you can modify this value in `.env` file directly.  If you prefer to use a randomly generated password, then leave the value empty when prompted to enter a password.

5. Deploy the stack

```bash
$ hub stack deploy
```

## Access the Kubeflow user interface (UI)
You can find the URL of deployed Kubeflow Dashboard using the `hub show` command and parameter `component.kubeflow.url`:
```bash
$ hub show
```


## Verify Kubeflow Deployment

Congratulations, you have just deployed Kubeflow! To make sure that all Kubeflow services are running as expected, you can use the following Kubeflow example: [MNIST Example](https://github.com/kubeflow/examples/tree/master/mnist)

1. Launch a Jupyter notebook

The tutorial has been tested using the Jupyter Tensorflow 1.15 image.

Launch a terminal in Jupyter and clone the kubeflow examples repo:

```
git clone https://github.com/kubeflow/examples.git git_kubeflow-examples
```

2. Open the notebook mnist/mnist_aws.ipynb

3. Follow the notebook to train and deploy MNIST model on Kubeflow


## Additional Options

### Redeploy one or more components

Redeploy one or more compomnents. The following commands will redeploy two stack components: `istio` and `prometheus`

```bash
$ hub stack undeploy -c istio,prometheus
$ hub stack deploy -c istio,prometheus
```

### Deploy all components starting from the pre-deployed component

Deploy the specified component and all subsequent components in the stack runlist.

```bash
$ hub stack deploy -o istio
```

## Tear Down

If you have used a default name to setup your cluster then you can use the following command to undeploy the entire stack:

```bash
$ hub stack undeploy
$ hub ext eks policy detach --cluster $STACK_NAME --all
$ eksctl delete cluster -f etc/eks-cluster.yaml
```

Otherwise, use the following command if the stack name was configured with variable `STACK_NAME`:

```bash
$ eksctl delete cluster --name="$STACK_NAME"
```
