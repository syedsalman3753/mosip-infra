#!/bin/bash
# Installs all regproc helm charts
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=regproc
CHART_VERSION=12.0.1-pre-production

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
  helm -n $NS install regproc-salt syed-nira/regproc-salt  --set-string nodeSelector.vlan="200" --version $CHART_VERSION --wait --wait-for-jobs

  echo Installing regproc-workflow
  helm -n $NS install regproc-workflow syed-nira/regproc-workflow  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing regproc-status
  helm -n $NS install regproc-status syed-nira/regproc-status  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing regproc-camel
  helm -n $NS install regproc-camel syed-nira/regproc-camel  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing regproc-pktserver
  helm -n $NS install regproc-pktserver syed-nira/regproc-pktserver  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing group1
  helm -n $NS install regproc-group1 syed-nira/regproc-group1 --set persistence.enabled=false  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing group2
  helm -n $NS install regproc-group2 syed-nira/regproc-group2   --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing group3
  helm -n $NS install regproc-group3 syed-nira/regproc-group3   --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing group4
  helm -n $NS install regproc-group4 syed-nira/regproc-group4  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing group5
  helm -n $NS install regproc-group5 syed-nira/regproc-group5  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing group6
  helm -n $NS install regproc-group6 syed-nira/regproc-group6  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing group7
  helm -n $NS install regproc-group7 syed-nira/regproc-group7  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing regproc-trans
  helm -n $NS install regproc-trans syed-nira/regproc-trans  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing regproc-notifier
  helm -n $NS install regproc-notifier syed-nira/regproc-notifier  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing regproc-reprocess
  helm -n $NS install regproc-reprocess syed-nira/regproc-reprocess  --set-string nodeSelector.vlan="200" --version $CHART_VERSION

  echo Installing regproc-landingzone
  helm -n $NS install regproc-landingzone syed-nira/regproc-landingzone --set image.repository="mosipid/registration-processor-landing-zone" --set image.tag=1.2.0.1  --set-string nodeSelector.vlan="200" --version 0.0.1-develop

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
