#!/bin/bash

function connected_external_drive_backup_server_data() {


    VAR_SERVER_USER=$"phano"
    VAR_SERVER_HOST=$"data_mine:"
    VAR_SERVER_PREF=$"@"
    VAR_SERVER_DIR=$"/var/www/hdrive/web_php/"
    VAR_SERVER_DEST=$"/var/www/bdrive/web_php/"
    VAR_LOCAL_DEST=$"/mnt/d/web_php/"


    echo -e "\t [*] ################ \e[1;42mBacking Linux Server Web Data\e[0m ################"
    echo ""
    rsync --update -raz --progress ${VAR_SERVER_DIR} ${VAR_SERVER_DEST}
    echo ""
    echo -e "\t [*] ############### \e[1;42mBacking Linux Server Completed\e[0m ################"
    echo ""


}

function server_test() {

    VAR_DIR_ONE=$"/var/www/testone/"
    VAR_DIR_TWO=$"/var/www/testtwo/"


    echo -e "\t [*] Running Test Transfer...."
    rsync --update -raz --progress ${VAR_DIR_ONE} ${VAR_DIR_TWO}
    echo -e "\t [*] Test completed successfully."

}

connected_external_drive_backup_server_data
#server_test
