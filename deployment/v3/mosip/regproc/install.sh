#!/bin/bash
# Installs all regproc helm charts
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=regproc
CHART_VERSION=12.0.1-prod

echo Create $NS namespace
kubectl create ns $NS

function installing_regproc() {
  echo Istio label
  kubectl label ns $NS istio-injection=enabled --overwrite
  helm repo update

  echo Copy configmaps
  sed -i 's/\r$//' copy_cm.sh
  ./copy_cm.sh

  echo Running regproc-salt job
  helm -n $NS install regproc-salt nira/regproc-salt  --version $CHART_VERSION --wait --wait-for-jobs

  echo Installing regproc-workflow
  helm -n $NS install regproc-workflow nira/regproc-workflow  --version $CHART_VERSION -f ./workflow-values.yaml

  echo Installing regproc-status
  helm -n $NS install regproc-status nira/regproc-status  --version $CHART_VERSION -f ./status-values.yaml

  echo Installing regproc-camel
  helm -n $NS install regproc-camel nira/regproc-camel  --version $CHART_VERSION -f ./camel-values.yaml

  echo Installing regproc-pktserver
  helm -n $NS install regproc-pktserver nira/regproc-pktserver  --version $CHART_VERSION -f ./pktserver-values.yaml

  echo Installing group1
  helm -n $NS install regproc-group1 nira/regproc-group1 --set persistence.enabled=true --set-string persistence.storageClass="nfs-csi"  --version $CHART_VERSION -f ./group1-values.yaml

  echo Installing group2
  helm -n $NS install regproc-group2 nira/regproc-group2   --version $CHART_VERSION -f ./group2-values.yaml

  echo Installing group3
  helm -n $NS install regproc-group3 nira/regproc-group3   --version $CHART_VERSION -f ./group3-values.yaml

  echo Installing group4
  helm -n $NS install regproc-group4 nira/regproc-group4  --version $CHART_VERSION -f ./group4-values.yaml

  echo Installing group5
  helm -n $NS install regproc-group5 nira/regproc-group5  --version $CHART_VERSION -f ./group5-values.yaml

  echo Installing group6
  helm -n $NS install regproc-group6 nira/regproc-group6  --version $CHART_VERSION -f ./group6-values.yaml

  echo Installing group7
  helm -n $NS install regproc-group7 nira/regproc-group7  --version $CHART_VERSION -f ./group7-values.yaml

  echo Installing group8
  helm -n $NS install regproc-group8 nira/regproc-group8  --version $CHART_VERSION -f ./group8-values.yaml

  echo Installing group9
  helm -n $NS install regproc-group9 nira/regproc-group9  --version $CHART_VERSION -f ./group9-values.yaml

  echo Installing group10
  helm -n $NS install regproc-group10 nira/regproc-group10  --version $CHART_VERSION -f ./group10-values.yaml

  echo Installing regproc-trans
  helm -n $NS install regproc-trans nira/regproc-trans  --version $CHART_VERSION -f ./trans-values.yaml

  echo Installing regproc-notifier
  helm -n $NS install regproc-notifier nira/regproc-notifier  --version $CHART_VERSION -f ./notifier-values.yaml

  echo Installing regproc-reprocess
  helm -n $NS install regproc-reprocess nira/regproc-reprocess  --version $CHART_VERSION -f ./reprocess-values.yaml

  echo Installing regproc-reprocess-3
  helm -n $NS install regproc-reprocess-3 nira/regproc-reprocess  --version $CHART_VERSION -f ./reprocess-3-values.yaml

  echo Installing regproc-reprocess-processing-status
  helm -n $NS install regproc-reprocess-processing-status nira/regproc-reprocess  --version $CHART_VERSION -f ./reprocess-status-values.yaml

  echo Installing regproc-landingzone
  helm -n $NS install regproc-landingzone nira/regproc-landingzone  --version $CHART_VERSION -f ./landingzone-values.yaml

  kubectl -n $NS  get deploy -o name |  xargs -n1 -t  kubectl -n $NS rollout status
  echo Intalled regproc services
  return 0
}

# set commands for error handling.
set -e
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errtrace  # trace ERR through 'time command' and other functions
set -o pipefail  # trace ERR through pipes
installing_regproc   # calling function
