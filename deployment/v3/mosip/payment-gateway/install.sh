#!/bin/bash
# Installs payments
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=payments
CHART_VERSION=12.0.1-prod

echo Create $NS namespace
kubectl create ns $NS 

helm repo add nira-payment-gateway https://niragit.github.io/mosip-helm/

function installing_payments() {
  echo Istio label
  kubectl label ns $NS istio-injection=enabled --overwrite
  helm repo update

  echo Copy configmaps
  sed -i 's/\r$//' copy_cm.sh
  ./copy_cm.sh

  echo Installing payments
  helm -n $NS install nira-payment-gateway nira/nira-payment-gateway --version $CHART_VERSION -f values.yaml

  kubectl -n $NS  get deploy -o name |  xargs -n1 -t  kubectl -n $NS rollout status
  return 0
}

# set commands for error handling.
set -e
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errtrace  # trace ERR through 'time command' and other functions
set -o pipefail  # trace ERR through pipes
installing_payments   # calling function
