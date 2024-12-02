#!/usr/bin/env bash
set -o nounset

POSIXLY_CORRECT=1
export POSIXLY_CORRECT
LANG=C
readonly NAMESPACE="cert-manager"
readonly REGISTRY="quay.io"
readonly IMAGE="upmio/upm-engine-deploy"
readonly VERSION="v1.2.2"

# check minikube binary exists
if ! command -v minikube >/dev/null 2>&1; then
  echo "minikube is not installed."
  exit 1
fi

# check namespace exists
minikube kubectl -- get namespace $NAMESPACE 2>/dev/null || {
  echo "Namespace $NAMESPACE not found."
  exit 2
}

# create ClusterRoleBinding if not exists
cat <<EOF | minikube kubectl -- apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: upm-system-admin-default-account
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: $NAMESPACE
EOF

# check cert-manager-uninstall job is exist
if minikube kubectl -- get jobs -n cert-manager 2>/dev/null | grep -q "^cert-manager-uninstall"; then
  echo "cert-manager-uninstall is already exist.Please wait for the installation to complete."
  echo "You can check the logs by running 'kubectl logs -n cert-manager -l job-name=cert-manager-uninstall'."
  exit 3
fi

# create job to uninstall cert-manager
cat <<EOF | minikube kubectl -- apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: cert-manager-uninstall
  namespace: cert-manager
spec:
  template:
    metadata:
      name: cert-manager-uninstall
    spec:
      containers:
      - name: cert-manager-deploy
        image: $REGISTRY/$IMAGE:$VERSION
        command: ["/upm-deploy/cert-manager-uninstall.sh"]
        env:
        - name: ASSUMEYES
          value: "true"
      restartPolicy: Never
  backoffLimit: 0
EOF

# wait for job to complete and output job log
sleep 5
minikube kubectl -- logs -f -n cert-manager -l job-name=cert-manager-uninstall --since=10s | tee  cert-manager-uninstall.log &

while true; do
  sleep 3
  JOB_STATUS=$(minikube kubectl -- get job -n cert-manager cert-manager-uninstall -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}')
  if [[ "$JOB_STATUS" == "True" ]]; then
    minikube kubectl -- delete job -n cert-manager cert-manager-uninstall
    break
  fi
  JOB_STATUS=$(minikube kubectl -- get job -n cert-manager cert-manager-uninstall -o jsonpath='{.status.conditions[?(@.type=="Failed")].status}')
  if [[ "$JOB_STATUS" == "True" ]]; then
    echo "Failed to uninstall cert-manager."
    echo "You can check the logs by running 'kubectl logs -n cert-manager -l job-name=cert-manager-uninstall'."
    exit 4
  fi
done