#!/bin/bash
echo "##### Creating PEM Key ########"
create_pem(){
PEM_FILE_NAME= "$1"
pwd
ls -a
ssh-keygen -m PEM -t rsa -b 4096 -f ./${PEM_FILE_NAME} -N nasunipassphrase
ls -a

}
PEM_FILE_NAME="nac_vm_key.pem"
create_pem $PEM_FILE_NAME
VAULT_TFVARS="vault.tfvars"
chmod 400 $PEM_FILE_NAME
echo "pem-key-path="\"$PEM_FILE_NAME\" >>$VAULT_TFVARS
