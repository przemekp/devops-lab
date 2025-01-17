# K8s on Azure

## Table of Contents

- [Introduction](#introduction)
- [Getting Started](#getting-started)
    - [Install tools](#install-tools)
    - [Create storage account](#create-storage-account-in-azure)
    - [Export environment variables](#export-environment-variables)
- [Usage](#usage)
    - [Run Terraform](#run-terraform)
    - [Run Trivy](#run-trivy-optional)
    - [Run Rover](#install-rover-optional)
    - [Run Terraform Docs](#run-terraform-docs)
    - [Run Pre-commit Manually](#run-pre-commit-manually)
- [Maintenance](#maintenance)

## Introduction

#TODO:

## Getting started

Tools used by this project:
- [pre-commit hooks](https://pre-commit.com/#intro)
- [Terraform](https://developer.hashicorp.com/terraform)
- Terraform plugins:
  - [tfenv](https://github.com/tfutils/tfenv)
  - [tflint](https://github.com/terraform-linters/tflint)
  - [terraform-docs](https://github.com/terraform-docs/terraform-docs)
  - [rover](https://github.com/im2nguyen/rover)
- [trivy](https://trivy.dev/latest/)

### Install tools
 - [pre-commit hooks](https://pre-commit.com/#install)

    After installation run:
    ```bash
    pre-commit install
    ```

 - [tfenv](https://github.com/tfutils/tfenv?tab=readme-ov-file#installation)
 - Terraform:

    Install using tfenv
    ```bash
    tfenv install #version is read from .terraform-version
    tfenv use <tf_version_in_.terraform-version_file> #1.10.0
    ```

 - [tflint](https://github.com/terraform-linters/tflint?tab=readme-ov-file#installation)
 - [terraform-docs](https://github.com/terraform-docs/terraform-docs?tab=readme-ov-file#installation)
 - [rover](https://github.com/im2nguyen/rover?tab=readme-ov-file#installation)
 - [trivy](https://trivy.dev/latest/getting-started/installation/)

### [Create storage account in Azure](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal)

After creation of Storage Account export following values:
```bash
export AZURE_RSG=<put-your-value>
export AZURE_STORAGE_ACCOUNT_NAME=<put-your-value>
export AZURE_STORAGE_CONTAINER_NAME=<put-your-value>
```

### [Create User Assigned Managed Identity in Azure]{https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp}

After User Assigned Identity is created, assign it correct permissions so Terraform can deploy resources to your Subscription (for tests Owner role is best)

### Setup environment variables
Select one method:
- export environment variables
  ```bash
  export ARM_CLIENT_ID=00000000-0000-0000-0000-000000000000 # user assigned managed identity client id
  export ARM_SUBSCRIPTION_ID=00000000-0000-0000-0000-000000000000
  export ARM_TENANT_ID=00000000-0000-0000-0000-000000000000
  export TF_DATA_DIR=./.terraform/<supported-environment> # demo
  export TF_ENV=<supported-environment> # demo
  export LAB=<selected-lab> #e.g. lab-0-terraform
  ```
- create script to setup all these variables
  ```bash
  cp scripts/set-azure-env.sh.template scripts/set-azure-env.sh
  ```

  Adjust:
  - ARM_CLIENT_ID,
  - ARM_SUBSCRIPTION_ID,
  - ARM_TENANT_ID,
  - AZURE_RSG,
  - AZURE_STORAGE_ACCOUNT_NAME,
  - AZURE_STORAGE_CONTAINER_NAME

  to correct values

  Run script:
  ```bash
  source scripts/set-azure-env.sh -e <supported-environment> -l <selected-lab> #e.g. demo, lab-0-terraform
  ```

## Usage

Commands to run project locally

### Run Terraform

Make sure that environment variables are set from command line or by the [script](#setup-environment-variables)

Make sure you're in correct directory: terraform/${LAB}

Run Terraform init:
```bash
terraform init -backend-config="key=${LAB}.tfstate" \
  -backend-config="resource_group_name=${AZURE_RSG}" \
  -backend-config="storage_account_name=${AZURE_STORAGE_ACCOUNT_NAME}" \
  -backend-config="container_name=${AZURE_STORAGE_CONTAINER_NAME}"
```

Run Terraform plan:
```bash
terraform plan -var-file ../env/${LAB}/${TF_ENV}.tfvars
```

Run Terraform apply
```bash
terraform apply -var-file ../env/${LAB}/${TF_ENV}.tfvars
```
or with auto-approve set
```bash
terraform apply -var-file ../env/${LAB}/${TF_ENV}.tfvars -auto-approve
```

Run Terraform destroy
```bash
terraform destroy -var-file ../env/${LAB}/${TF_ENV}.tfvars
```

### Run trivy

Make sure you're in correct directory: terraform/${LAB}

HTML Template file trivy_html_template.tpl was downloaded from https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl

Prepare artifacts for report generation:
```bash
terraform plan -var-file ../env/${LAB}/${TF_ENV}.tfvars -out=../../reports/${LAB}-${TF_ENV}-plan.tfplan
terraform show -json ../../reports/${LAB}-${TF_ENV}-plan.tfplan > ../../reports/${LAB}-${TF_ENV}-plan.json
trivy fs --format template --template "@../../trivy_html_template.tpl" -o ../../reports/${LAB}-${TF_ENV}-report.html ../../reports/${LAB}-${TF_ENV}-plan.json
```

Check report.html file.

### Run rover

Make sure you're in correct directory: terraform/${LAB}

Prapare plan and generate report
```bash
terraform plan -var-file ../env/${LAB}-${TF_ENV}.tfvars -out=../../reports/${LAB}-${TF_ENV}-plan.tfplan
terraform show -json ../../reports/${LAB}-${TF_ENV}-plan.tfplan > ../../reports/${LAB}-${TF_ENV}-plan.json
rover -planJSONPath ../../reports/${LAB}-${TF_ENV}-plan.json
```

Or generate report in one go
```bash
rover -workingDir . -tfPath "/opt/homebrew/bin/terraform"  --tfVarsFile ../env/${LAB}/${TF_ENV}.tfvars
```

Open in browser 0.0.0.0:9000 to view results. Results can be saved as files if you pass -standalone option to rover command.

### Run Terraform Docs

Make sure you're in correct directory: terraform/${LAB}

Generate Terraform documentation

```bash
terraform-docs .
```

### Run Pre-commit Manually

Run pre-commit checks manually:

```bash
pre-commit run --all-files
```

to skip specific pre-commit checks use:

```bash
SKIP=<specific check> pre-commit run
```

to skip all pre-commit checks use:
```bash
git commit --no-verify -m "your commit message"
```

## Maintenance
Following components need maintenance:
- all tools mentioned in [Getting Started](#getting-started)
- all tools in [.pre-commit-config.yaml](.pre-commit-config.yaml)
- Terraform providers in ./terraform/modules/*/versions.tf
