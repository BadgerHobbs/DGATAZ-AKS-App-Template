FROM mcr.microsoft.com/devcontainers/base:jammy

# Install Terraform
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends rcm \
    && curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list \
    && apt update \
    && apt -y install --no-install-recommends terraform

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install k9s
COPY install_k9s.sh /usr/local/bin/install_k9s.sh
RUN chmod +x /usr/local/bin/install_k9s.sh && /usr/local/bin/install_k9s.sh && rm /usr/local/bin/install_k9s.sh

# Set default kubeconfig path to the Terraform export.
ENV KUBECONFIG=./Terraform/kubeconfig.yaml
