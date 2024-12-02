#!/usr/bin/env bash
set -o nounset

POSIXLY_CORRECT=1
export POSIXLY_CORRECT
LANG=C
readonly NAMESPACE="upm-system"
readonly REGISTRY="quay.io"
readonly IMAGE="upmio/upm-platform-deploy"
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

# check upm-platform-install job is exist
if minikube kubectl -- get jobs -n $NAMESPACE 2>/dev/null | grep -q "^upm-platform-install"; then
  echo "upm-platform-install is already exist.Please wait for the installation to complete."
  echo "You can check the logs by running 'kubectl logs -n upm-system -l job-name=upm-platform-install'."
  exit 3
fi

# create job to install upm-platform
cat <<EOF | minikube kubectl -- apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: upm-platform-install
  namespace: $NAMESPACE
spec:
  template:
    metadata:
      name: upm-platform-install
    spec:
      containers:
      - name: upm-platform-deploy
        image: $REGISTRY/$IMAGE:$VERSION
        command: ["/upm-deploy/upm-install.sh"]
        env:
        - name: ASSUMEYES
          value: "true"
        - name: ENV_YAML
          value: /upm-deploy/yaml/upm/minikube-quickstart.yaml
      restartPolicy: Never
  backoffLimit: 0
EOF

# wait for job to complete and output job log
sleep 5
minikube kubectl -- logs -f -n $NAMESPACE -l job-name=upm-platform-install --since=10s | tee  upm-platform-install.log &

while true; do
  sleep 3
  JOB_STATUS=$(minikube kubectl -- get job -n $NAMESPACE upm-platform-install -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}')
  if [[ "$JOB_STATUS" == "True" ]]; then
    kubectl delete job -n $NAMESPACE upm-platform-install
    break
  fi
  JOB_STATUS=$(minikube kubectl -- get job -n $NAMESPACE upm-platform-install -o jsonpath='{.status.conditions[?(@.type=="Failed")].status}')
  if [[ "$JOB_STATUS" == "True" ]]; then
    echo "Failed to install upm-platform."
    echo "You can check the logs by running 'kubectl logs -n upm-system -l job-name=upm-platform-install'."
    exit 4
  fi
done
