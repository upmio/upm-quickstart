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

# check job is exist
if minikube kubectl -- get jobs -n $NAMESPACE 2>/dev/null | grep -q "^upm-platform-uninstall"; then
  echo "upm-platform-uninstall is already exist.Please wait for the installation to complete."
  echo "You can check the logs by running 'kubectl logs -n upm-system -l job-name=upm-platform-uninstall'."
  exit 3
fi

# create job to install upm-platform
cat <<EOF | minikube kubectl -- apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: upm-platform-uninstall
  namespace: $NAMESPACE
spec:
  template:
    metadata:
      name: upm-platform-uninstall
    spec:
      containers:
      - name: upm-platform-deploy
        image: $REGISTRY/$IMAGE:$VERSION
        command: ["/upm-deploy/upm-uninstall.sh"]
        env:
        - name: ASSUMEYES
          value: "true"
      restartPolicy: Never
  backoffLimit: 0
EOF

# wait for job to complete and output job log
sleep 5
minikube kubectl -- logs -f -n $NAMESPACE -l job-name=upm-platform-uninstall --since=10s | tee  upm-platform-uninstall.log &

while true; do
  sleep 3
  JOB_STATUS=$(minikube kubectl -- get job -n $NAMESPACE upm-platform-uninstall -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}')
  if [[ "$JOB_STATUS" == "True" ]]; then
    minikube kubectl -- delete job -n $NAMESPACE upm-platform-uninstall
    break
  fi
  JOB_STATUS=$(minikube kubectl -- get job -n $NAMESPACE upm-platform-uninstall -o jsonpath='{.status.conditions[?(@.type=="Failed")].status}')
  if [[ "$JOB_STATUS" == "True" ]]; then
    echo "Failed to uninstall upm-platform."
    echo "You can check the logs by running 'kubectl logs -n upm-system -l job-name=upm-platform-uninstall'."
    exit 4
  fi
done
