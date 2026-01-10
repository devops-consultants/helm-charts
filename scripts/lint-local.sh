#!/bin/bash
# Script to run chart-testing lint locally
# This replicates the lint-test GitHub Actions workflow

set -e

# Add yamllint to PATH
export PATH="$HOME/.local/bin:$PATH"

# Check prerequisites
command -v ct >/dev/null 2>&1 || { echo "Error: ct not found. Please install chart-testing."; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "Error: helm not found."; exit 1; }
command -v yamllint >/dev/null 2>&1 || { echo "Error: yamllint not found. Install with: pipx install yamllint"; exit 1; }

echo "Running chart-testing lint..."
ct lint --config ct.yaml --charts charts/courselit --validate-chart-schema=false

echo ""
echo "✓ All linting checks passed!"
