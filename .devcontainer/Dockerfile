FROM mcr.microsoft.com/devcontainers/base:bullseye

# Set the Arguments for the Dockerfile
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="false"
ARG PWSH_VERSION="v7.4.3"
ARG PWSH_FILENAME="powershell_7.4.3-1.deb_amd64.deb"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install common-debian configs and dependencies
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" 

# Install Powershell Core
RUN wget -q https://github.com/PowerShell/PowerShell/releases/download/${PWSH_VERSION}/${PWSH_FILENAME} \
    && sudo dpkg -i ${PWSH_FILENAME} \
    && apt-get update -y \
    && apt-get install -f \
    && rm -f ${PWSH_FILENAME}

# Install Azure Powershell Modules
RUN pwsh -c "Install-Module -Name Az -Force" \
    && pwsh -c "Install-Module -Name AzureAD -RequiredVersion 2.0.2.140 -Force" \
    && pwsh -c "Install-Module -Name Microsoft.Graph -Force" \
    && pwsh -c "Install-Module -Name powershell-yaml -Force"

# Install Azure Tools
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash 

# Install Terraform & Packer
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y terraform packer \
    && terraform --version \
    && packer --version

# Install Ansible
RUN apt-get install -y ansible \
    && ansible-galaxy collection install azure.azcollection

# User Scope
USER ${USERNAME}
