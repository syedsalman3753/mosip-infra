#!/bin/bash
# Installs the mvs module
# Make sure you have updated ui_values.yaml
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=mvs
CHART_VERSION=12.0.1-prod

echo Create $NS namespace
kubectl create ns $NS

helm repo add nira https://niragit.github.io/mosip-helm/

function installing_mvs() {
  echo Istio label
  kubectl label ns $NS istio-injection=enabled --overwrite
  helm repo update

  echo Copy configmaps
  sed -i 's/\r$//' copy_cm.sh
  ./copy_cm.sh

  #echo login to docker
  #sed -i 's/\r$//' dockerlogin.sh
  #./dockerlogin.sh

  API_HOST=$(kubectl get cm global -o jsonpath={.data.mosip-api-internal-host})
  mvs_HOST=$NS.$(kubectl get cm global -o jsonpath={.data.mosip-mvs-host})

  echo Installing mvs-Proxy into Masterdata and Keymanager.
  kubectl -n $NS apply -f mvs-proxy.yaml

  echo Installing ms service. Will wait till service gets installed.
  helm -n $NS install mvs-service nira/mvs-service --version $CHART_VERSION -f ./mvs-service-values.yaml --wait

  echo Installing mvs-ui
  helm -n $NS install mvs-ui nira/mvs-ui  --set mvs.apiUrl=https://$mvs_HOST --set istio.hosts[0]=$mvs_HOST --version $CHART_VERSION -f ./mvs-ui-values.yaml

  kubectl -n $NS  get deploy -o name |  xargs -n1 -t  kubectl -n $NS rollout status

  echo Installed mvs services

  echo "manual-verification-system portal URL: https://$mvs_HOST/mvs-ui/"
  return 0
}

# set commands for error handling.
set -e
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errtrace  # trace ERR through 'time command' and other functions
set -o pipefail  # trace ERR through pipes
installing_mvs   # calling function
