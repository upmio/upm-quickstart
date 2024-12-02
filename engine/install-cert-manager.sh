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

# create namespace if not exists
minikube kubectl -- get namespace $NAMESPACE 2>/dev/null || {
  minikube kubectl -- create namespace $NAMESPACE || {
    echo "Failed to create namespace $NAMESPACE."
    exit 2
  }
}

# create ClusterRoleBinding if not exists
cat <<EOF | minikube kubectl -- apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cert-manager-admin-default-account
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: $NAMESPACE
EOF

# check cert-manager-install job is exist
if minikube kubectl -- get jobs -n cert-manager 2>/dev/null | grep -q "^cert-manager-install"; then
  echo "cert-manager-install is already exist.Please wait for the installation to complete."
  echo "You can check the logs by running 'kubectl logs -n cert-manager -l job-name=cert-manager-install'."
  exit 3
fi

# create job to install cert-manager
cat <<EOF | minikube kubectl -- apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: cert-manager-install
  namespace: cert-manager
spec:
  template:
    metadata:
      name: cert-manager-install
    spec:
      containers:
      - name: cert-manager-deploy
        image: $REGISTRY/$IMAGE:$VERSION
        command: ["/upm-deploy/cert-manager-install.sh"]
        env:
        - name: ASSUMEYES
          value: "true"
        - name: ENV_YAML
          value: /upm-deploy/yaml/cert-manager/minikube-quickstart.yaml
      restartPolicy: Never
  backoffLimit: 0
EOF

# wait for job to complete and output job log
sleep 5
minikube kubectl -- logs -f -n cert-manager -l job-name=cert-manager-install --since=10s | tee  cert-manager-install.log &

while true; do
  sleep 3
  JOB_STATUS=$(minikube kubectl -- get job -n cert-manager cert-manager-install -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}')
  if [[ "$JOB_STATUS" == "True" ]]; then
    minikube kubectl -- delete job -n cert-manager cert-manager-install
    break
  fi
  JOB_STATUS=$(minikube kubectl -- get job -n cert-manager cert-manager-install -o jsonpath='{.status.conditions[?(@.type=="Failed")].status}')
  if [[ "$JOB_STATUS" == "True" ]]; then
    echo "Failed to install cert-manager."
    echo "You can check the logs by running 'kubectl logs -n cert-manager -l job-name=cert-manager-install'."
    exit 4
  fi
done