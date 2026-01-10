#!/bin/bash
# Script to run chart-testing install locally using kind
# This replicates the install portion of the lint-test GitHub Actions workflow

set -e

# Add yamllint to PATH
export PATH="$HOME/.local/bin:$PATH"

# Check prerequisites
command -v ct >/dev/null 2>&1 || { echo "Error: ct not found. Please install chart-testing."; exit 1; }
command -v kind >/dev/null 2>&1 || { echo "Error: kind not found. Please install kind."; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "Error: helm not found."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "Error: kubectl not found."; exit 1; }

CLUSTER_NAME="chart-testing"

# Check if kind cluster already exists
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "Using existing kind cluster: ${CLUSTER_NAME}"
else
    echo "Creating kind cluster: ${CLUSTER_NAME}..."
    kind create cluster --name "${CLUSTER_NAME}" --wait 300s
fi

echo ""
echo "Installing charts with chart-testing..."
ct install --config ct.yaml --charts charts/courselit

echo ""
echo "✓ Chart installation test passed!"
echo ""
echo "To interact with the cluster, use: kubectl --context kind-${CLUSTER_NAME}"
echo "To delete the cluster, run: kind delete cluster --name ${CLUSTER_NAME}"
