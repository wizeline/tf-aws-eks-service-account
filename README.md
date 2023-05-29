# Terraform AWS EKS Service Account

Terraform module to spin up Kubernetes service accounts with AWS IAM resources.

## Usage

**Prerequisits**
* An AWS accocunt.

* An existing EKS cluster with:
    
    * An existing IAM OpenID Connect (OIDC) provider.

### Examples

**Basic**
A service account without any IAM permissions attached to the role neither tags for your resources:

```terraform
module "example" {
  source = "github.com/wizeline/tf-aws-eks-service-account.git?ref=v0.0.1"

  name          = "example"
  oidc_provider = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}
```

**Advanced**
A service account deployed in your `example` kubernetes namespace with an IAM role with full permissions over ECR resources and add some tags for the AWS resources you are going to create:

```terraform
module "example" {
  source = "github.com/wizeline/tf-aws-eks-service-account.git?ref=v0.0.1"

  name          = "example"
  oidc_provider = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
  iam_policy_statements = [
    {
        effect    = "Allow"
        actions   = ["ecr:*"]
        resources = ["*"]
    }
  ]
  k8s_namespace = "example"


  tags = {
    "Name"        = "example"
    "department"  = "engineering"
    "environment" = "test"
  }
}
```
