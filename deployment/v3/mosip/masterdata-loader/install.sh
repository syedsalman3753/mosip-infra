#!/bin/bash
# Loads sample masterdata 
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

echo  WARNING: This need to be executed only once at the begining for masterdata deployment. If reexecuted in a working env this will reset the whole master_data DB tables resulting in data loss.
echo  Please skip this if masterdata is already uploaded.
read -p "CAUTION: Do you still want to continue(Y/n)" yn
if [ $yn = "Y" ]
  then
   NS=masterdata-loader
   CHART_VERSION=12.0.1-pre-production
   helm delete masterdata-loader -n $NS
   echo Create $NS namespace
   kubectl create ns $NS

   # set commands for error handling.
   set -e
   set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
   set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
   set -o errtrace  # trace ERR through 'time command' and other functions
   set -o pipefail  # trace ERR through pipes

   echo Istio label
   kubectl label ns $NS istio-injection=enabled --overwrite
   helm repo add syed-nira https://syedsalman3753.github.io/mosip-helm-nira
   helm repo update

   echo Copy configmaps
   sed -i 's/\r$//' copy_secrets.sh
   ./copy_secrets.sh

   read -p "Please provide Database host " DB_HOST
   if [[ -z $DB_HOST ]]; then
     echo "DB HOST variable not provided; EXITING";
     exit 1;
   fi
   read -p "Please provide Database port " DB_PORT
   if [[ -z $DB_PORT ]]; then
     echo "DB PORT variable not provided; EXITING";
     exit 1;
   fi

   echo Loading masterdata
   helm -n $NS install masterdata-loader  syed-nira/masterdata-loader \
   --set mosipDataGithubRepoUrl="https://github.com/syed-nira/mosip-data" \
   --set mosipDataGithubBranch="v1.2.0.1" \
   --set db.host="$DB_HOST" \
   --set db.port="$DB_PORT" \
   --set db.user="masteruser" \
   --set db.secret.name="db-common-secrets" \
   --set db.secret.key="db-dbuser-password" \
   --set-string nodeSelector.vlan="200" \
   --version $CHART_VERSION --wait --wait-for-jobs 
   else
     echo "Masterdata loader not executed"
fi
