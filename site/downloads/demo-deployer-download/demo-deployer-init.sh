#!/bin/bash
############################################################
#Author           : Dave Krier
#Author email     : dakriern@us.ibm.com
#Original Date    : 2023-05-18
############################################################
BASE_URL=https://pages.github.ibm.com/Daffy-Internal/demo-deployer-doc
CONTEXT=downloads/demo-deployer-download
RED_TEXT=`tput setaf 1`
GREEN_TEXT=`tput setaf 2`
ORANGE_TEXT=`tput setaf 5`
BLUE_TEXT=`tput setaf 6`
RESET_TEXT=`tput sgr0`
DEMO_DEPLOYER_INSTALL_TAR=demo-deployer.tar.gz

OS_NAME=`uname`
if [ ${OS_NAME} == "Linux" ] ;then
    if [ "$EUID" -ne 0 ] ; then
      echo "${RED_TEXT}Please run as root!!!!!!"
      echo "${RED_TEXT}Exiting Script!!!!!!!${RESET_TEXT}"
      exit 99
    fi
fi

#Cleanup File before we start
rm -fR demo-deployer-init.sh &> /dev/null

if [ ${OS_NAME} == "Linux" ]; then
  if [  -d "/data/demo-deployer" ]; then
     mkdir -p /tmp/demo-deployer-update  &> /dev/null
     mkdir -p /tmp/demo-deployer-update/log  &> /dev/null
     cp -f --preserve=timestamps /data/demo-deployer/scripts/user-vars.sh /tmp/demo-deployer-update/ &> /dev/null
     cp -fR --preserve=timestamps /data/demo-deployer/log/* /tmp/demo-deployer-update/log &> /dev/null
     rm -fR /data/demo-deployer
   fi
   #Build Folder and start in that new location
   mkdir -p /data &> /dev/null
   cd /data
   #Downlaod Demo-deployer Install Tool
   wget ${BASE_URL}/${CONTEXT}/${DEMO_DEPLOYER_INSTALL_TAR}
   tar -xvf ${DEMO_DEPLOYER_INSTALL_TAR} &> /dev/null
   rm -fR  ${DEMO_DEPLOYER_INSTALL_TAR} &> /dev/null
   cp -fR --preserve=timestamps /tmp/demo-deployer-update/log /data/demo-deployer/ &> /dev/null
   cp  --preserve=timestamps /tmp/demo-deployer-update/user-vars.sh /data/demo-deployer/scripts/
   rm -fR /tmp/demo-deployer-update &> /dev/null
   chmod -fR 755 /data/demo-deployer
else
 echo "Only supported on Linux"  
 exit 99
fi

#Cleanup File post install
rm -fR demo-deployer-init.sh &> /dev/null
echo ""
echo "##########################################################################################################"
echo "Demo Deployer  Location                : /data/demo-deployer/"
echo "##########################################################################################################"
