# DGATAZ-AKS-App-Template

[![Build and Push Docker Image](https://github.com/BadgerHobbs/DGATAZ-AKS-App-Template/actions/workflows/build-and-push-docker-image.yaml/badge.svg)](https://github.com/BadgerHobbs/DGATAZ-AKS-App-Template/actions/workflows/build-and-push-docker-image.yaml) [![Deploy to Azure](https://github.com/BadgerHobbs/DGATAZ-AKS-App-Template/actions/workflows/deploy-to-azure.yaml/badge.svg)](https://github.com/BadgerHobbs/DGATAZ-AKS-App-Template/actions/workflows/deploy-to-azure.yaml) [![Destroy Digital Ocean Deployment](https://github.com/BadgerHobbs/DGATAZ-AKS-App-Template/actions/workflows/deploy-to-azure.yaml/badge.svg)](https://github.com/BadgerHobbs/DGATAZ-AKS-App-Template/actions/workflows/destroy-azure-deployment.yaml)

A demo/template repository for building and deploying an application using Docker, GitHub Actions, Terraform, Azure, and AKS.

## Automatic (CI/CD) Deployment

### Create GitHub Access Token

Go to GitHub and create a classic personal access token with both repository and package read/write permissions. These permissions are required so that the `terraform-state` GitHub Action can download the latest Terraform state file artifacts, as well as so the Docker image can be pushed to the GitHub Container Registry (GHCR).

### Create Azure Service Account

Fist of all, if you don't already have an Azure account, create one. Afterwards, login with the following command.

```bash
az login --use-device-code
```

Next, use the following to create a service principle account which will be used to deploy the application to Azure. Save the details provided as some of these will be secrets in GitHub for deployment.

```bash
az ad sp create-for-rbac --name DGATAZAKSAppServicePrinciple
```

Use the following comand to get your Azure subscription ID, this will needed to assign the role for the service account.

```bash
az account show --query "{ subscription_id: id }"
```

Then run the following command to assign a contributor role to the service account, enabling it to deploy Azure resources.

```bash
az role assignment create --assignee <appId> --role Contributor --scope /subscriptions/<your_subscription_id>
```

### Set GitHub Action Secrets

Go to GitHub and set the following secrets to be used within the various GitHub Actions for building and deploying. You can find documentation on setting secrets [here](https://docs.github.com/en/actions/security-guides/encrypted-secrets).

```
AZURE_SUBSCRIPTION_ID
AZURE_TENTANT_ID
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
GHCR_USERNAME
GHCR_ACCESS_TOKEN
GH_ACCESS_TOKEN
ENCRYPTION_KEY
```

## Manual Deployment

### Create GitHub Access Token and Login to GitHub Container Registry

Go to GitHub and create a personal access token with repository read/write permissions, as documented [here](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry).

Use the following command to login using your username and token.

```bash
docker login ghcr.io -u <USERNAME> -p <GITHUB_PAT>
```

### Build, Tag, and Push Docker Image

Run the following commands to build the application Docker image, then tag it, then push it to the GitHub container registry.

```bash
docker build -t dgataz-aks-application:latest -f Docker/Dockerfile .
```

```bash
docker dgataz-aks-application:latest ghcr.io/<USERNAME>/dgatdo-application:latest
```

```bash
docker push ghcr.io/<USERNAME>/dgataz-aks-application:latest
```

### Set Terraform Variables

Copy and rename the `template.tfvars` file to `local.tfvars` and update the values.

### Intialise and Deploy using Terraform

Run the following commands to deploy the application using Terraform, making sure to answer `yes` to confirmation prompts for `plan` and `deploy`.

```bash
terraform -chdir="./Terraform" init
```

```bash
terraform -chdir="./Terraform" plan -var-file="local.tfvars"
```

```bash
terraform -chdir="./Terraform" apply -var-file="local.tfvars"
```

You can confirm that the resource have been deployed using the following command.

```bash
az aks list --resource-group dgataz-aks-app-resources --output table
```

### Destroy Deployment using Terraform

Run the following command to destroy your previously deployed application using Terraform, making sure to answer `yes` to confirm destruction.

```bash
terraform -chdir="./Terraform" destroy -var-file="local.tfvars"
```

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE).
