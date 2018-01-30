#!/bin/bash

# Print env out so we can see what is getting passed into us from orchestrator.
ENVOUT="/opt/openbaton/scripts/gw_instantiate.env"
echo "====================================================" >> ${ENVOUT}
echo "Environment relevant to gw_instantiate.sh script: " >> ${ENVOUT}
env >> ${ENVOUT}
echo "" >> ${ENVOUT}
echo "====================================================" >> ${ENVOUT}
logger "gw_instantiate: INSTANTIATION of the Gateway"

WANADDR=`ip r get $(ip r show 0.0.0.0/0 | grep -oP 'via \K\S+') | grep -oP 'src \K\S+'`
if [ -z ${WANADDR} ]; then
   logger "gw_instantiate:ERR: No WAN-side IP Address. " 
else
   logger "gw_instantiate:INFO: WAN-side IP Address: ${WANADDR}" 
fi

logger "gw_instantiate: Hostname: ${hostname}"
logger "gw_instantiate: Traffic Interface: ${ifacetraffic}" 
logger "gw_instantiate: Data Port: ${portdata}" 
logger "gw_instantiate: CallP Port: ${portcallp}" 

logger "gw_instantiate: INFO: Someone, OpenStack or the Orchestrator, has CloudInit resetting the sysctl.conf file." 
logger "gw_instantiate: INFO: We will attempt to set the socket buffer receive parm here."
logger "gw_instantiate: INFO: This will alleviate an alarm that complains about this parm being set too low."

# Obviously we need to be running this script as root to do this. Fortunately we are.
PARMPATH='/proc/sys/net/core/rmem_max'
echo 'net.core.rmem_max=2048000' >> /etc/sysctl.conf
sysctl -p 
if [ $? -eq 0 ]; then
   logger "gw_instantiate: INFO: Call to sysctl appears to be successful."
   logger "gw_instantiate: INFO: Verifying Socket Buffer Receive Parameter."
   echo "Socket Buffer Receive Parm rmem_max is now: `cat ${PARMPATH}`" | logger
else
   logger "gw_instantiate: WARN: Call to sysctl appears to have failed."
   logger "gw_instantiate: WARN: Please set net.core.rmem_max parameter to 2048000 manually to avoid alarm."
fi
exit 0
