#!/bin/bash
# Installs all prereg helm charts
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=prereg
CHART_VERSION=12.0.1-prod

echo Create $NS namespace
kubectl create ns $NS

function installing_prereg() {
  echo Istio label
  ## TODO: Istio proxy disabled for now as prereui does not come up if
  ## envoy filter container gets installed after prereg container.
  kubectl label ns $NS istio-injection=disabled --overwrite
  helm repo update

  echo Copy configmaps
  sed -i 's/\r$//' copy_cm.sh
  ./copy_cm.sh

  API_HOST=`kubectl get cm global -o jsonpath={.data.mosip-api-host}`
  PREREG_HOST=`kubectl get cm global -o jsonpath={.data.mosip-prereg-host}`

  echo Install prereg-gateway
  helm -n $NS install prereg-gateway nira/prereg-gateway --set istio.hosts[0]=$PREREG_HOST --version $CHART_VERSION

  #echo Installing prereg-captcha
  #helm -n $NS install prereg-captcha nira/prereg-captcha  --set-string nodeSelector.vlan="100" --version $CHART_VERSION -f ../ha-values.yaml

  echo Installing prereg-application
  helm -n $NS install prereg-application nira/prereg-application   --version $CHART_VERSION -f ./application-values.yaml

  echo Installing prereg-booking
  helm -n $NS install prereg-booking nira/prereg-booking  --version $CHART_VERSION -f ./booking-values.yaml

  echo Installing prereg-datasync
  helm -n $NS install prereg-datasync nira/prereg-datasync  --version $CHART_VERSION -f ./datasync-values.yaml

  echo Installing prereg-batchjob
  helm -n $NS install prereg-batchjob nira/prereg-batchjob  --version $CHART_VERSION -f ./batchjob-values.yaml

  echo Installing prereg-ui
  helm -n $NS install prereg-ui nira/prereg-ui  --set prereg.apiHost=$PREREG_HOST --version $CHART_VERSION -f ./prereg-ui-values.yaml

  echo Installing prereg rate-control Envoyfilter
  kubectl apply -n $NS -f rate-control-envoyfilter.yaml

  kubectl -n $NS  get deploy -o name |  xargs -n1 -t  kubectl -n $NS rollout status

  echo Installed prereg services
  return 0
}

# set commands for error handling.
set -e
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errtrace  # trace ERR through 'time command' and other functions
set -o pipefail  # trace ERR through pipes
installing_prereg   # calling function
