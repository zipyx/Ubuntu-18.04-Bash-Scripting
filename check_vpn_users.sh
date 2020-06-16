#!/bin/bash

# PASS Directory and file name
PASSFILE=$"bit.txt"
PASSDIR=$"/home/passfix/${PASSFILE}"

# VPN Directory and file name
VPNFILE=$"users_online.txt"
VPNUSER=$"user_vpn_list.txt"

# VPN script stored on local computer --> name of script stored in variable
VPNSCRIPT=$"run_vpn_script"
VPNSCRIPTDIR=$"/home/phano/vpn_users/"

# Home Dir
HOME=$"/home/phano/"

function activate_vpn_script() {

    # Connect to Remove server using SSHPASS and activating bash script
    # sshpass -f ${PASSDIR} ssh -q phano@nzauckpp247vpn "bash -s" < ${VPNSCRIPT}
    sshpass -f ${PASSDIR} ssh -q phano@nzauckpp247vpn "pivpn -c > ${VPNSCRIPTDIR}${VPNFILE}"
    sshpass -f ${PASSDIR} ssh -q phano@nzauckpp247vpn "pivpn -l > ${VPNSCRIPTDIR}${VPNUSER}"

    retrieve_result

}


function retrieve_result() {

    # rsync -avzhe ssh
    sshpass -f ${PASSDIR} scp -q phano@nzauckpp247vpn:${VPNSCRIPTDIR}${VPNFILE} ${HOME}
    sshpass -f ${PASSDIR} scp -q phano@nzauckpp247vpn:${VPNSCRIPTDIR}${VPNUSER} ${HOME}
    sshpass -f ${PASSDIR} ssh -q phano@nzauckpp247vpn "rm ${VPNSCRIPTDIR}${VPNFILE}"
    sshpass -f ${PASSDIR} ssh -q phano@nzauckpp247vpn "rm ${VPNSCRIPTDIR}${VPNUSER}"

    # Test Display Results
    cat ${HOME}${VPNUSER}
    cat ${HOME}${VPNFILE}
    rm ${HOME}${VPNFILE}
    rm ${HOME}${VPNUSER}
}

activate_vpn_script
