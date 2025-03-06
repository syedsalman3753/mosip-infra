#!/bin/bash
# Installs config-server
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=config-server
CHART_VERSION=12.0.1-pre-production

read -p "Is conf-secrets module installed?(Y/n) " conf_installed
if [[  -z $conf_installed || $conf_installed != "Y" ]]; then
  echo "Input 'conf-secrets module installed' is either empty or not 'Y'; EXITING";
  exit 1;
fi

local_enabled=false
read -p "Do you want to enable config-server to pull configurations from local repository?(Y/n)( Default: n )" local_enabled
if [[ -n $local_enabled && $local_enabled == "Y" ]]; then
  local_enabled=true
fi

persistence_enabled=false
read -p "Do you want to enable persistence volume for local repository?(Y/n)( Default: n )" persistence_enabled
if [[ -n $persistence_enabled && $persistence_enabled == "Y" ]]; then
  persistence_enabled=true
fi

nfs_enabled=false
NFS_ARGS=''
read -p "Do you want to enable persistence volume with NFS server?(Y/n)( Default: n ) "  nfs_enabled
if [[ -n $nfs_enabled && $nfs_enabled == "Y" ]]; then
  # Regular expressions
  ip_regex='^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]?[0-9])$'
  hostname_regex='^(([a-zA-Z0-9-]+\.)*[a-zA-Z0-9-]+)$'

  # Prompt for input
  read -p "Please provide NFS host: " nfs_host
  # Validate input
  if ! [[ $nfs_host =~ $ip_regex || $nfs_host =~ $hostname_regex ]]; then
      echo "The NFS host is neither a valid IP address nor a valid hostname."
      exit 1;
  fi

  # Check if the host is reachable
  if ! ping -c 1 -W 2 "$nfs_host" &> /dev/null; then
      echo "The host '$nfs_host' is not reachable."
      exit 1;
  fi

  read -p "Please provide NFS path: " nfs_path

  # Regular expression for directory structure
  dir_regex='^(\/[a-zA-Z0-9._-]+)+\/?$'

  # Validate directory structure
  if ! [[ $nfs_path =~ $dir_regex ]]; then
      echo "The input '$nfs_path' is not a valid directory structure."
      exit 1;
  fi

  NFS_ARGS="--set persistence.nfs.host=\"$nfs_host\" --set persistence.nfs.path=\"$nfs_path\""

fi

if [ $conf_installed = "Y" ]; then
  read -p "Is values.yaml for config-server chart set correctly as part of Pre-requisites?(Y/n) " yn;
fi
if [ $yn = "Y" ]
  then
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
    helm repo add tf-nira https://tf-nira.github.io/mosip-helm-nira
    helm repo update

    echo Copy configmaps
    sed -i 's/\r$//' copy_cm.sh
    ./copy_cm.sh

    echo Copy secrets
    sed -i 's/\r$//' copy_secrets.sh
    ./copy_secrets.sh

    echo "Installing config-server"
    helm -n $NS install config-server tf-nira/config-server \
    --set gitRepo.localRepo.enabled="$local_enabled" \
    --set persistence.enabled="$persistence_enabled" \
    --set-string nodeSelector.vlan="200" \
    -f values.yaml \
    --wait --wait-for-jobs --version $CHART_VERSION  $NFS_ARGS
    echo "Installed Config-server".
  else
    echo Exiting the MOSIP installation. Please meet the pre-requisites and than start again.
    kill -9 `ps --pid $$ -oppid=`; exit
fi
