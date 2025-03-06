#!/bin/bash
# Installs idrepo
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=idrepo
CHART_VERSION=12.0.1-pre-production

echo Create $NS namespace
kubectl create ns $NS

function installing_idrepo() {
  echo Istio label
  kubectl label ns $NS istio-injection=enabled --overwrite
  helm repo update

  echo Copy configmaps
  sed -i 's/\r$//' copy_cm.sh
  ./copy_cm.sh

  echo Running salt generator job
  helm -n $NS install idrepo-saltgen  tf-nira/idrepo-saltgen  --set-string nodeSelector.vlan="200" --version $CHART_VERSION --wait --wait-for-jobs

  echo Running credential
  helm -n $NS install credential tf-nira/credential  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Running credential request service
  helm -n $NS install credentialrequest tf-nira/credentialrequest  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Running identity service
  helm -n $NS install identity tf-nira/identity  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Running vid service
  helm -n $NS install vid tf-nira/vid  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  kubectl -n $NS  get deploy -o name |  xargs -n1 -t  kubectl -n $NS rollout status
  echo Installed idrepo services
  return 0
}

# set commands for error handling.
set -e
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errtrace  # trace ERR through 'time command' and other functions
set -o pipefail  # trace ERR through pipes
installing_idrepo   # calling function
