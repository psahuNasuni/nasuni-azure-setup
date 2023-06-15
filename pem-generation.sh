#!/bin/bash
echo "##### INFO ::: Creating PEM Key :: Started ########"
PEM_FILE_NAME="$1"
pwd
ls -a
ssh-keygen -m PEM -t rsa -b 4096 -f ./${PEM_FILE_NAME} -N nasunipassphrase
ls -a
chmod 400 $PEM_FILE_NAME
echo "##### INFO ::: Creating PEM Key :: Completed ########"