# Keymanager

## Install
NOTE: Keymanager runs in a separate namespace from other kernel modules (for security, access restrictions)
* Create `keymanager` namespace
```
$ kubectl create namespace keymanager
```
* Copy all config maps from other namespaces
```
$ ./copy_cm.sh
```
* Helm install
```
$ helm repo add mosip https://mosip.github.io/mosip-helm
$ helm repo update
$ helm -n keymanager install keymanager mosip/keymanager 
```

## Create base keys 
This has to be done one-time. The job here will create base keys in HSM/Softhsm that must be kept intact throughout the project.  This job must be run ONLY ONCE.  It is assumed that HSM or SoftHsm is already installed.
* Make sure properties in `application-default.properties` and `kernel-default.properties` are property set to generate your organization's certificates.
* Run the job
```
$ helm -n keymanager install kernel-keygen mosip/kernel-keygen
```

