# Key Manager

## Overview
[Key Manager](https://docs.mosip.io/1.2.0/modules/keymanager) runs in a separate namespace from other [Kernel modules](https://docs.mosip.io/1.2.0/modules/commons) (for security, access restrictions). Before running Key Manager, [Base keys](https://docs.mosip.io/1.2.0/modules/keymanager#key-hierarchy) need to be generated.  This is done by [key generation job](https://docs.mosip.io/1.2.0/modules/keymanager#key-generation-process). The job creates Base keys in HSM/Softhsm. These keys must be kept intact throughout the project. It is assumed that HSM/Softhsm is already installed and properties in [`application-default.properties`](https://docs.mosip.io/1.2.0/modules/module-configuration#config-server) and `kernel-default.properties` are appropriately set to generate your organization's certificates.

## Install

Here is a more professional version of the README points:

* **Create a ConfigMap**: In the `softhsm` namespace, create a ConfigMap named `softhsm-kernel-share`. Set the key `PKCS11_PROXY_SOCKET` with a value that specifies the HSM service URL as `tcp://<HOST/IP>:<PORT>`.
* **Create a Secret**: In the `softhsm` namespace, create a Secret named `softhsm-kernel`. Set the key `security-pin` with the HSM access key as its value.
* **Verify KeyManager Dependencies**: Before installing the KeyManager module, confirm that `softhsm-kernel` Secret are shared with the Config-Server service.
* The key generator job and Key Manager installation is done by running the below script:
```
./install.sh
```


