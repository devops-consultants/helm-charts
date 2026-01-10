# Chart Testing with kind - Known Issues

## MongoDB StatefulSet PVC Issue

### Problem

When running `ct install` with kind clusters, the MongoDB StatefulSet fails to start because:

1. Kind uses `WaitForFirstConsumer` volume binding mode by default
2. StatefulSets require PVCs to be bound before scheduling pods
3. `WaitForFirstConsumer` requires pods to be scheduled before binding PVCs
4. This creates a deadlock where neither the pod nor PVC can proceed

### Symptoms

- MongoDB pod stays in `Pending` state indefinitely
- PVC shows status `Waiting for first consumer to be created before binding`
- `helm install --wait` times out after 10 minutes
- GitHub Actions workflow hangs on "Run chart-testing (install)" step

### Solutions

#### Option 1: Use Test MongoDB Deployment (Recommended for CI)

Use the `ci/test-with-mongodb-pod.yaml` values file which:
- Disables the StatefulSet-based MongoDB
- Deploys a simple MongoDB Deployment with emptyDir (no persistence)
- Avoids the PVC deadlock entirely

```bash
ct install --config ct.yaml --charts charts/courselit --helm-extra-set-args "--values=charts/courselit/ci/test-with-mongodb-pod.yaml"
```

**Note**: The `extraManifests` feature needs to be implemented in the chart templates.

#### Option 2: Pre-provision PVCs

Create PVCs manually before installing:

```bash
kubectl create -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-courselit-mongodb-0
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
  volumeMode: Filesystem
EOF
```

#### Option 3: Use Different Storage Class

Configure kind with `Immediate` binding mode storage class, or modify the chart to use it.

### Current Status

The chart includes:
- ✅ `createTestSecrets: true` option to auto-generate test secrets for CI
- ✅ `ci/default-values.yaml` - Uses StatefulSet (has PVC issue)
- ✅ `ci/test-with-mongodb-pod.yaml` - Uses Deployment (needs extraManifests template)
- ❌ `extraManifests` template not yet implemented

### TODO

1. Implement `extraManifests` template to support arbitrary Kubernetes manifests in values
2. OR modify MongoDB StatefulSet template to support emptyDir when `mongodb.useEmptyDir: true`
3. Update GitHub Actions workflow to use working CI values file
