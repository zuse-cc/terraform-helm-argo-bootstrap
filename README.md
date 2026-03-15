# terraform-helm-argo-bootstrap

Terraform wrapper module to bootstrap generic ArgoCD application stacks using helm.

## Prerequisites

Terraform, `jq` and a recent version of the [Github CLI](https://cli.github.com/) are required.

## Usage

This module acts as a thin wrapper around a helm chart that will do the actual deployment. See https://github.com/joerx/cloudlab/tree/main/charts/bootstrap-argo for an example chart that can be used with this module.

### Code Formatting

To format all Terraform code, test and tfvars files:

```sh
make fmt
```

### Tests

The following will run all included Terraform tests locally:

```sh
make test
```

## Releasing

To create a new release in GH, which will also publish release assets:

```sh
make release VERSION=v0.2.1
```
