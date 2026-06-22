#!/usr/bin/env bash

set -euo pipefail

echo "================================================="
echo " Kubernetes / Azure / GitOps Workstation Setup"
echo "================================================="

# --------------------------------------------------
# Base packages
# --------------------------------------------------

sudo apt update

sudo apt install -y \
    git \
    jq \
    tmux \
    tree \
    curl \
    wget \
    unzip \
    gnupg \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    graphviz \
    default-jre \
    snapd

# --------------------------------------------------
# yq
# --------------------------------------------------

if ! command -v yq >/dev/null 2>&1; then
    echo "Installing yq..."
    sudo wget -qO /usr/local/bin/yq \
        https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    sudo chmod +x /usr/local/bin/yq
fi

# --------------------------------------------------
# kubectl
# --------------------------------------------------

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Installing kubectl..."

    curl -fsSL \
      https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key \
      | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    echo \
      "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" \
      | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

    sudo apt update
    sudo apt install -y kubectl
fi

# --------------------------------------------------
# Helm
# --------------------------------------------------

if ! command -v helm >/dev/null 2>&1; then
    echo "Installing Helm..."

    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# --------------------------------------------------
# Azure CLI
# --------------------------------------------------

if ! command -v az >/dev/null 2>&1; then
    echo "Installing Azure CLI..."

    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# --------------------------------------------------
# ArgoCD CLI
# --------------------------------------------------

if ! command -v argocd >/dev/null 2>&1; then
    echo "Installing ArgoCD CLI..."

    VERSION=$(curl -s \
      https://api.github.com/repos/argoproj/argo-cd/releases/latest \
      | jq -r .tag_name)

    curl -sSL -o argocd \
      "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64"

    chmod +x argocd
    sudo mv argocd /usr/local/bin/
fi

# --------------------------------------------------
# k9s
# --------------------------------------------------

if ! command -v k9s >/dev/null 2>&1; then
    echo "Installing k9s..."

    K9S_VERSION=$(curl -s \
      https://api.github.com/repos/derailed/k9s/releases/latest \
      | jq -r .tag_name)

    curl -sSL \
      "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" \
      -o k9s.tar.gz

    tar -xzf k9s.tar.gz
    sudo mv k9s /usr/local/bin/

    rm -f k9s.tar.gz LICENSE README.md
fi

# --------------------------------------------------
# stern
# --------------------------------------------------

if ! command -v stern >/dev/null 2>&1; then
    echo "Installing stern..."

    STERN_VERSION=$(curl -s \
      https://api.github.com/repos/stern/stern/releases/latest \
      | jq -r .tag_name)

    curl -sSL \
      "https://github.com/stern/stern/releases/download/${STERN_VERSION}/stern_${STERN_VERSION#v}_linux_amd64.tar.gz" \
      -o stern.tar.gz

    tar -xzf stern.tar.gz

    sudo mv stern /usr/local/bin/

    rm -f stern.tar.gz
fi

# --------------------------------------------------
# kubectx + kubens
# --------------------------------------------------

if ! command -v kubectx >/dev/null 2>&1; then
    echo "Installing kubectx + kubens..."

    sudo rm -rf /opt/kubectx

    sudo git clone \
      https://github.com/ahmetb/kubectx \
      /opt/kubectx

    sudo ln -sf \
      /opt/kubectx/kubectx \
      /usr/local/bin/kubectx

    sudo ln -sf \
      /opt/kubectx/kubens \
      /usr/local/bin/kubens
fi

# --------------------------------------------------
# PlantUML
# --------------------------------------------------

if ! command -v plantuml >/dev/null 2>&1; then
    echo "Installing PlantUML..."

    sudo apt install -y plantuml
fi

# --------------------------------------------------
# Summary
# --------------------------------------------------

echo
echo "============================================="
echo " Installed versions"
echo "============================================="

echo
git --version || true
jq --version || true
yq --version || true
kubectl version --client || true
helm version || true
az version | head -n 3 || true
argocd version --client || true
k9s version || true
stern --version || true
plantuml -version | head -n 2 || true

echo
echo "============================================="
echo " Control Workstation ready."
echo "============================================="