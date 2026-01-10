# Chart Testing with kind

## ✅ Fixed: MongoDB StatefulSet PVC Issue

### Solution Implemented

Added `mongodb.storage.useEmptyDir` option to use emptyDir instead of PVC for CI testing.

**Usage:**

```yaml
mongodb:
  enabled: true
  useOperator: false
  storage:
    useEmptyDir: true  # Uses emptyDir instead of PVC
```

This is now enabled by default in `ci/default-values.yaml` and resolves the WaitForFirstConsumer deadlock.

### Original Problem

When running `ct install` with kind clusters, the MongoDB StatefulSet would fail to start because:

1. Kind uses `WaitForFirstConsumer` volume binding mode by default
2. StatefulSets require PVCs to be bound before scheduling pods
3. `WaitForFirstConsumer` requires pods to be scheduled before binding PVCs
4. This creates a deadlock where neither the pod nor PVC can proceed

### Testing Locally

```bash
# Run linting
./scripts/lint-local.sh

# Test installation with kind
cd /home/coder/helm-charts
helm install test charts/courselit --values charts/courselit/ci/default-values.yaml --wait

# Verify emptyDir is used (no PVCs should exist)
kubectl get pvc
kubectl get pod -o jsonpath='{.spec.volumes[0]}' <mongodb-pod-name>
```

### Production Deployments

For production, keep `useEmptyDir: false` (default) to use persistent storage with PVCs.

**Warning:** When `useEmptyDir: true`, MongoDB data is not persisted and will be lost when the pod is deleted.
