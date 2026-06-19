# --------------------------------------------------
# Docker
# --------------------------------------------------

if ! command -v docker >/dev/null 2>&1; then
    echo "Installing Docker..."

    curl -fsSL https://get.docker.com | sudo sh

    sudo systemctl enable docker
    sudo systemctl start docker

    sudo usermod -aG docker "$USER"

    echo
    echo "NOTE: Re-login may be required for docker group membership."
    exit
fi

# --------------------------------------------------
# Kubernetes kernel prerequisites
# --------------------------------------------------

if ! lsmod | grep -q '^br_netfilter'; then
    echo "Loading br_netfilter..."
    sudo modprobe br_netfilter
fi

if ! lsmod | grep -q '^overlay'; then
    echo "Loading overlay..."
    sudo modprobe overlay
fi

# --------------------------------------------------
# k3d
# --------------------------------------------------

if ! command -v k3d >/dev/null 2>&1; then
    echo "Installing k3d..."

    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# --------------------------------------------------
# Local Kubernetes Cluster
# --------------------------------------------------

CLUSTER_NAME="hello-world"

if ! k3d cluster list | awk '{print $1}' | grep -qx "${CLUSTER_NAME}"; then
    echo "Creating k3d cluster: ${CLUSTER_NAME}"

    k3d cluster create "${CLUSTER_NAME}" \
        --agents 1 \
        --servers 1 \
        -p "8080:80@loadbalancer" \
        --wait
fi

# --------------------------------------------------
# Verify cluster
# --------------------------------------------------

kubectl cluster-info

kubectl get nodes

echo "Wait for the nodes to signal 'ready'"

kubectl wait --for=condition=Ready node --all --timeout=120s
kubectl get pods -A