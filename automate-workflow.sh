#!/bin/bash

function menu() {

    echo ""
    echo ""
    echo " ##################### Cervg Bash Script Tool ###################### "
    echo " ###############<----> Author: Setephano (V.1) <---->############### "
    echo ""
    echo ""
    echo "[*] What would you like to do? "
    echo ""
    echo ""
    echo -e "\t [1] ---> Backup Entire Server Site to Drive (Sdb1) "
    echo -e "\t [2] ---> Create New User Profile Folder Base {Drive & Web Profile}"
    echo -e "\t [3] ---> Delete User Profile Folder Base {Drive & Web Profile}"
    echo -e "\t [4] ---> Update User Profile Base Permissions."
    echo -e "\t [5] ---> Restore Server Site from Backup - cervg.com "
    echo -e "\t [6] ---> Restore Server Site from Backup - fam.cervg.com "
    echo -e "\t [7] ---> Create New Sub Domain - *.cervg.com "
    echo -e "\t [8] ---> Remove Sub Domain and all binding services [kestrel] if available - *.cervg.com "
    echo -e "\t [9] ---> Activate Kestrel Service Dotnet - kestrel-*.service "
    echo -e "\t [10] ---> Deactivate Kestrel Service Dotnet - kestrel-*.service "
    echo -e "\t [11] ---> Deploy dotnet application to apache server"
    echo""
    echo""
    printf "[+] Please select a number: "
    operation


}

function operation() {

    read -r user_input

    if [[ $user_input == "1" ]]; then
        echo "[+] Selected $user_input"
        echo ""
        server_backup
    elif [[ $user_input == "2" ]]; then
        echo "[+] Selected $user_input"
        echo ""
        create_new_user_base
    elif [[ $user_input == "3" ]]; then
        echo "[+] Selected $user_input"
        echo ""
        delete_user_base
    elif [[ $user_input == "4" ]]; then
        echo "[+] Selected $user_input"
        echo ""
        set_new_permission
    elif [[ $user_input == "5" ]]; then
        echo "[+] Selected $user_input"
        domain_cervg
    elif [[ $user_input == "6" ]]; then
        echo "[+] Selected $user_input"
        subdomain_cervg
    elif [[ $user_input == "7" ]]; then
        echo "[+] Selected $user_input"
        create_subdomain
    elif [[ $user_input == "8" ]]; then
        echo "[+] Selected $user_input"
        remove_subdomain
    elif [[ $user_input == "9" ]]; then
        echo "[+] Selected $user_input"
        enable_kestrel_service
    elif [[ $user_input == "10" ]]; then
        echo "[+] Selected $user_input"
        disable_kestrel_service
    elif [[ $user_input == "11" ]]; then
        echo "[+] Selected $user_input"
        deploy_dotnet_app
    elif [[ $user_input == "clear"  || $user_input == "reset" ]]; then
        clear
        menu
    elif [[ $user_input == "ls" || $user_input == "list" ]]; then
        echo ""
        echo "----------> User List <---------->"
        echo ""
        ls -1 /var/www/subfileserve/cervg/users/
        echo ""
        echo "--------------------------------->"
        echo ""
        menu
    elif [[ $user_input == "exit" ]]; then
        echo "[+] Selected $user_input"
        exit
    else
        echo "[-] Invalid Input : Please Try Again. "
        menu
fi
}

function deploy_dotnet_app() {
    echo ""
    printf "[*] Would you like to deploy a dotnet app to apache server now? "
    read -r user_deploy_app_answer
    echo ""
    if [[ $user_deploy_app_answer == "Yes" || $user_deploy_app_answer == "yes" || $user_deploy_app_answer == "y" || $user_deploy_app_answer == "YES" ]]; then

        # Get dotnet published apps if available
        mapfile array < <(find $HOME -type d -iname publish)
        for i in "${!array[@]}"; do printf "\t%s\t%s" "--> [$i]" "${array[$i]}"; done
        echo ""
        printf "[*] Enter a dotnet application number to deploy to apache server: "
        read -r user_app_select
        if [[ $user_app_select == "" ]]; then
            echo ""
            deploy_dotnet_app
        elif [[ $user_app_select == "menu" || $user_app_select == "Menu" || $user_app_select == "MENU" ]]; then
            echo ""
            menu
        elif [[ $user_app_select == "clear" || $user_app_select == "Clear" || $user_app_select == "CLEAR" ]]; then
            echo ""
            clear
            deploy_dotnet_app
        elif [[ $user_app_select == "quit" || $user_app_select == "exit" || $user_app_select == "EXIT" ]]; then
            echo ""
            exit
        fi
        echo ""

        # Get Desitination apache server
        echo ""
        mapfile deplocation < <(ls -d /var/www/*)
        for i in "${!deplocation[@]}"; do printf "\t%s\t%s" "--> [$i]" "${deplocation[$i]}"; done
        echo ""
        printf "[*] Enter a designated destination number to deploy to [ensure subdomain is created already]: "
        read -r deploy_destination

        # Variables containing directories/user selected directory choice
        VAR_SEPERATOR=$"/"
        VAR_DEPLOY=$"${array[$user_app_select]}"
        VAR_DEST=$"${deplocation[$deploy_destination]}"
        VAR_DEFAULT_DEST=$"/var/www"
        VAR_FINAL_DESTINATION=$"${VAR_DEPLOY//[[:space:]]/}${VAR_SEPERATOR}"

        if [[ $deploy_destination == "" ]]; then
            echo ""
            echo -e "\t"
            printf "[*] Enter a name to register a subdomain directory in apache server: "
            read -r new_subdomain
            VAR_NEW_DIRECTORY=$"${VAR_DEFAULT_DEST}/${new_subdomain}"
            # Deploy app to destination
            echo -e "\t [+] Registering new directory into apache server..."
            echo -e "\t [+] Retrieving application from ${array[$user_app_select]}"
            echo -e "\t [+] Deploying application to apache server..."
            cp -rv $VAR_DEPLOY $VAR_NEW_DIRECTORY
            # Verbose completion
            echo -e "\t [+] Deployment successful."
            menu
        elif [[ $deploy_destination == "menu" || $deploy_destination == "Menu" || $deploy_destination == "MENU" ]]; then
            echo ""
            menu
        elif [[ $deploy_destination == "quit" || $deploy_destination == "exit" || $deploy_destination == "EXIT" ]]; then
            exit
        fi
        echo ""

        # Deploy app to destination
        echo -e "\t [+] Retrieving application from ${array[$user_app_select]}"
        echo -e "\t [+] Deploying application to apache server..."
        rsync -avzh $VAR_FINAL_DESTINATION $VAR_DEST

        # Verbose completion
        echo -e "\t [+] Deployment successful."
        menu
    else
        echo ""
        echo -e "\t [+] Services completed."
        menu
    fi
}

function list_of_kestrel_services() {
    echo ""
    echo "############ Kestrel List ############"
    awk 'BEGIN{ print "\nObtaining List ...\n"} { print FILENAME; nextfile }END{ print "\n... List Completed\n"} ' /etc/systemd/system/kestrel*
    echo "#####################################"
    echo ""
}

function enable_kestrel_service() {
    list_of_kestrel_services
    KESTREL_VAR=$"kestrel"
    printf "[*] Please enter kestrel service name to enable [subdomain name is generally service name]: "
    read -r kestrel_file_input
    
    # Located Kestrel file in directory --> /etc/systemd/system
    LOCATED_KESTREL_FILE=$"${KESTREL_VAR}-${kestrel_file_input}.service"
    
    if [[ -f "/etc/systemd/system/${LOCATED_KESTREL_FILE}" ]]; then
        # verbose kestrel file as being located
        echo -e "\t [+] Located file --> ${LOCATED_KESTREL_FILE}..."

        # Enable kestrel file link
        systemctl enable ${LOCATED_KESTREL_FILE}
        echo -e "\t [+] Enabling kestrel service for ${LOCATED_KESTREL_FILE}..."

        # Starting kestrel service
        systemctl start ${LOCATED_KESTREL_FILE}
        echo -e "\t [+] Starting kestrel service for ${LOCATED_KESTREL_FILE}..."

        # Restarting kestrel service
        # systemctl reload ${LOCATED_KESTREL_FILE}
        systemctl restart ${LOCATED_KESTREL_FILE}
        echo -e "\t [+] Restarting kestrel service for ${LOCATED_KESTREL_FILE}..."
        systemctl status ${LOCATED_KESTREL_FILE}
        echo ""
        menu
    elif [[ $kestrel_file_input == "clear"  || $kestrel_file_input == "reset" ]]; then
        clear
        enable_kestrel_service
    elif [[ $kestrel_file_input == "menu"  || $kestrel_file_input == "Menu" || $kestrel_file_input == "MENU" ]]; then
        menu
    else
        echo ""
        menu
    fi
}

function disable_kestrel_service() {
    list_of_kestrel_services
    KESTREL_VAR=$"kestrel"
    printf "[*] Please enter kestrel service name to disable [subdomain name is generally service name]: "
    read -r kestrel_file_input

    # Located Kestrel file in directory --> /etc/systemd/system
    LOCATED_KESTREL_FILE=$"${KESTREL_VAR}-${kestrel_file_input}.service"
    if [[ -f "/etc/systemd/system/${LOCATED_KESTREL_FILE}" ]]; then
        # verbose service as being found
        echo -e "\t [+] Located file --> ${LOCATED_KESTREL_FILE}..."

        # Disable kestrel file link
        systemctl disable ${LOCATED_KESTREL_FILE}
        echo -e "\t [+] Disabling kestrel service for ${LOCATED_KESTREL_FILE}..."

        # Starting kestrel service
        systemctl stop ${LOCATED_KESTREL_FILE}
        echo -e "\t [+] Stoping kestrel service for ${LOCATED_KESTREL_FILE}..."

        # Restarting kestrel service
        systemctl reload ${LOCATED_KESTREL_FILE}
        systemctl restart ${LOCATED_KESTREL_FILE}
        echo -e "\t [+] Restarting kestrel service for ${LOCATED_KESTREL_FILE}..."
        systemctl status ${LOCATED_KESTREL_FILE}
        echo ""
        menu
    elif [[ $kestrel_file_input == "clear"  || $kestrel_file_input == "reset" ]]; then
        clear
        disable_kestrel_service
    elif [[ $kestrel_file_input == "menu"  || $kestrel_file_input == "Menu" || $kestrel_file_input == "MENU" ]]; then
        menu
    else
        echo ""
        menu
    fi
}

function server_backup() {

    CASE_DOMAIN=$"backup_cervg_com"
    CASE_SUBDOMAIN=$"backup_fam_cervg_com"

    echo ""
    echo " ##########    Removing Old Backup of cervg.com   ##########"
    echo ""
    rm -r /var/www/hdrive/backup/${CASE_DOMAIN}/*
    echo " ##########           Action Completed            ########## "
    echo ""
    echo " ##########   Backing Up Live Cervg : cervg.com   ##########"
    echo ""
    cp -r /var/www/html/* /var/www/hdrive/backup/${CASE_DOMAIN}/
    echo ""
    echo " ##########           Action Completed            ########## "
    echo ""
    echo "<----------------------------------------------------------> "
    echo ""
    echo " ##########  Removing Old Backup of fam.cervg.com ##########"
    echo ""
    rm -r /var/www/hdrive/backup/${CASE_SUBDOMAIN}/*
    echo ""
    echo " ##########           Action Completed            ########## "
    echo ""
    echo " ##########  Backing Up Subdomain: fam.cervg.com  ##########"
    cp -r /var/www/subfileserve/* /var/www/hdrive/backup/${CASE_SUBDOMAIN}/
    echo ""
    echo " ##########           Action Completed            ########## "
    menu


}

function create_new_user_base() {

    echo ""
    printf "[*] Please enter a username to create: "
    read -r new_name

    if [[ -d "/var/www/subfileserve/cervg/users/$new_name" && -d "/var/www/hdrive/web_php/user_files/$new_name" ]]; then
        echo ""
        echo -e "\t [-] Username directories already exists [-]"
        create_new_user_base

    elif [[ $new_name == "ls" || $new_name == "list" ]]; then
        echo ""
        echo "----------> User List <---------->"
        echo ""
        ls -1 /var/www/subfileserve/cervg/users/
        echo ""
        echo "--------------------------------->"
        echo ""
        create_new_user_base

    else

        # Creating profile in hard drive
        echo ""
        echo -e "\t [+] Creating new user base in hdrive..."
        mkdir /var/www/hdrive/web_php/user_files/$new_name
        echo -e "\t [+] Successfully created."
        echo ""

        # Creating profile for web site
        echo -e "\t [+] Creating new user for web profile..."
        mkdir /var/www/subfileserve/cervg/users/$new_name
        echo -e "\t [+] Successful Created User: $new_name."
        echo ""

        # Direct to set permissions
        set_permission

fi
}

function delete_user_base() {

    echo ""
    printf "[*] Please enter a username to remove: "
    read -r remove_user

    if [[ $remove_user == "ls" || $remove_user == "list" ]]; then
        echo ""
        echo "----------> User List <---------->"
        echo ""
        ls -1 /var/www/subfileserve/cervg/users/
        echo ""
        echo "--------------------------------->"
        echo ""
        delete_user_base

    elif [[ $remove_user == "reset" || $remove_user == "clear" ]]; then
        clear
        delete_user_base

    elif [[ ! -d "/var/www/subfileserve/cervg/users/$remove_user" && ! -d "/var/www/hdrive/web_php/user_files/$remove_user" ]]; then
        echo ""
        echo -e "\t [-] Username: $remove_user directory doesn't exists [-]"
        delete_user_base

    else

        # Delete profile from hard drive
        echo ""
        echo -e "\t [+] Deleting $remove_user base from hdrive..."
        rm -r /var/www/hdrive/web_php/user_files/$remove_user
        echo -e "\t [+] Successfully deleted."
        echo ""

        # Delete profile from web base
        echo -e "\t [+] Deleting $remove_user from web profile..."
        rm -r /var/www/subfileserve/cervg/users/$remove_user
        echo -e "\t [+] Successful deleted User: $remove_user."
        echo ""

        # Direct to menu
        menu

fi
}

function set_permission() {

    echo ""
    echo -e "\t <---------- [*] Permission Sets [*] ---------->"
    echo ""
    echo -e "\t       [1] Basic (Movies|Files|Music)"
    echo -e "\t       [2] Inter (Movies/Anime|Files|Music|Calculus)"
    echo -e "\t       [3] Advan (Movies/Anime|Files|Music|Calculus|Books)"
    echo ""
    echo -e "\t <--------------------------------------------->"
    echo ""
    printf "[*] Invoke permissions number: "
    read -r get_permission

    if [[ $get_permission == "1" ]]; then
        echo "[+] Selected $get_permission"
        echo ""
        permission_one
    elif [[ $get_permission == "2" ]]; then
        echo "[+] Selected $get_permission"
        echo ""
        permission_two
    elif [[ $get_permission == "3" ]]; then
        echo "[+] Selected $get_permission"
        echo ""
        permission_three
    elif [[ $get_permission == "back" ]]; then
        echo "[+] Selected $get_permission"
        echo ""
        menu
    elif [[ $get_permission == "clear" || $get_permission == "reset" ]]; then
        clear
        set_permission
    elif [[ $get_permission == "exit" ]]; then
        echo "[+] Selected $get_permission"
        exit
    else
        echo -e "\t [-] Invalid Input : Please Try Again. "
        echo ""
        set_permission

fi
}

function set_new_permission() {

    echo ""
    echo -e "\t <---------- [*] Permission Sets [*] ---------->"
    echo ""
    echo -e "\t       [1] Basic (Movies|Files|Music)"
    echo -e "\t       [2] Inter (Movies/Anime|Files|Calculus)"
    echo -e "\t       [3] Advan (Movies/Anime|Files|Calculus|Books)"
    echo ""
    echo -e "\t <--------------------------------------------->"
    echo ""
    echo ""
    printf "[*] Enter username for permission set: "
    read -r check_username

    if [[ -d "/var/www/subfileserve/cervg/users/$check_username" && -d "/var/www/hdrive/web_php/user_files/$check_username" ]]; then

        printf "[*] Invoke permissions number: "
        read -r new_permission
        echo ""


        if [[ $new_permission == "1" ]]; then
            echo "[+] Selected $new_permission"
            echo ""
            permission_one
        elif [[ $new_permission == "2" ]]; then
            echo "[+] Selected $new_permission"
            echo ""
            permission_two
        elif [[ $new_permission == "3" ]]; then
            echo "[+] Selected $new_permission"
            echo ""
            permission_three
        elif [[ $new_permission == "back" ]]; then
            echo "[+] Selected $new_permission"
            echo ""
            menu
        elif [[ $new_permission == "clear" || $new_permission == "reset" ]]; then
            clear
            set_new_permission
        elif [[ $new_permission == "exit" ]]; then
            echo "[+] Selected $set_permission"
            exit
        else
            echo -e "\t [-] Invalid Input : Please Try Again. "
            echo ""
            set_new_permission
        fi

    elif [[ $check_username == "reset" || $check_username == "clear" ]]; then
        clear
        set_new_permission

    elif [[ $check_username == "ls" || $check_username == "list" ]]; then
        echo ""
        echo "----------> User List <---------->"
        echo ""
        ls -1 /var/www/subfileserve/cervg/users/
        echo ""
        echo "--------------------------------->"
        echo ""
        set_new_permission

    else
        echo -e "\t [-] Username doesn't exist"
        set_new_permission

fi
}

function permission_one() {
    printf "[*] Please Re-Enter username for validation: "
    read -r check_username
    if [[ -d "/var/www/subfileserve/cervg/users/$new_name" && -d "/var/www/hdrive/web_php/user_files/$new_name" ]]; then
        echo -e "\t [*] Setting Permissions..."
        rsync -cavu --progress --delete /var/www/subfileserve/cervg/permissions/one/ /var/www/subfileserve/cervg/users/$check_username
	#cp -r -v /var/www/subfileserve/cervg/permissions/one/* /var/www/subfileserve/cervg/users/${check_username}/
        echo -e "\t [+] Permission Set: Successful."
        menu
    else
        echo -e "\t [-] Permission Set One: Unsuccessful. Try again.."
        set_new_permission
fi
}

function permission_two() {

    printf "[*] Please Re-Enter username for validation: "
    read -r check_username
    if [[ -d "/var/www/subfileserve/cervg/users/$new_name" && -d "/var/www/hdrive/web_php/user_files/$new_name" ]]; then
        echo -e "\t [*] Setting Permissions..."
        rsync  -cavu --progress --delete /var/www/subfileserve/cervg/permissions/two/ /var/www/subfileserve/cervg/users/$check_username
	#cp -v -r /var/www/subfileserve/cervg/permissions/two/* /var/www/subfileserve/cervg/users/$check_username/
        echo -e "\t [+] Permission Set: Successful."
        menu
    else
        echo -e "\t [-] Permission Set two: Unsuccessful. Try again.."
        set_new_permission
fi
}

function permission_three() {

    printf "[*] Please Re-Enter username for validation: "
    read -r check_username
    if [[ -d "/var/www/subfileserve/cervg/users/$new_name" && -d "/var/www/hdrive/web_php/user_files/$new_name" ]]; then
        echo -e "\t [*] Setting Permissions..."
        rsync -cavu --progress --delete /var/www/subfileserve/cervg/permissions/three/ /var/www/subfileserve/cervg/users/$check_username
	#cp -v -r /var/www/subfileserve/cervg/permissions/three/* /var/www/subfileserve/cervg/users/$check_username/
        echo -e "\t [+] Permission Set: Successful."
        menu
    else
        echo -e "\t [-] Permission Set three: Unsuccessful. Try again.."
        set_new_permission
fi
}

function subdomain_cervg() {
    BACK_SUBDOMAIN=$"backup_fam_cervg_com"

    echo ""
    echo -e "\t [+] ######## Clearing fam.cervg.com Location ########"
    rm -r /var/www/subfileserve/*
    echo -e "\t [+] ############     Action Completed    ############"
    echo ""
    echo -e "\t [+] <----------------------------------------------->"
    echo ""
    echo -e "\t [+] ############  Placing Restore Point  ############"
    cp -r /var/www/hdrive/backup/${BACK_SUBDOMAIN}/* /var/www/subfileserve/
    echo -e "\t [+] ############     Action Completed    ############"
    menu

}

function domain_cervg() {
    BACK_DOMAIN=$"backup_cervg_com"

    echo ""
    echo -e "\t [+] ########## Clearing Cervg.com Location ##########"
    rm -r /var/www/html/*
    echo -e "\t [+] ############     Action Completed    ############"
    echo ""
    echo -e "\t [+] <----------------------------------------------->"
    echo ""
    echo -e "\t [+] ############  Placing Restore Point  ############"
    cp -r /var/www/hdrive/backup/${BACK_DOMAIN}/* /var/www/html/
    echo -e "\t [+] ############     Action Completed    ############"
    menu

}

function create_subdomain() {

    VAR1=$".cervg.com"
    VAR2=$".cervg.com.conf"
    VAR3=$"_access.log"
    VAR4=$"_error.log"
    VAR5=$".conf"
    VARDIR=$"/home/subdomain_templates/test/"
    VARDIR2=$"/home/subdomain_templates/dotnet.cervg.com.conf"
    VARDIR3=$"/home/subdomain_templates/"
    DOTNETCONFIG=$"dotnet.cervg.com.conf"

    function list_of_domains() {

        echo ""
        echo "############ Domain List ############"
        awk 'BEGIN{ print "\nObtaining List ...\n"} { print FILENAME; nextfile }END{ print "\n... List Completed\n"} ' /etc/apache2/sites-available/*.cervg.com.conf
        echo "#####################################"
        onrepeat_create_subdomain

    }


    function onrepeat_create_subdomain() {

        echo ""
        echo -e "\t <------------ !! DO NOT ENTER FULL DOMAIN !! ------------> "
        echo -e "\t [*] Example: yourdomain.cervg.com |||| Only: yourdomain [*]"
        echo -e "\t <--------------------------------------------------------> "
        echo ""

        # Get user input for name of new subdomain
        printf "[*] Please enter name for your new subdomain [Enter -> 'dotnet|c#' for dotnet subdomain creation]: "
        read -r new_sub
        VAR7=$"sub"

        if [[ $new_sub == "clear" || $new_sub == "reset" ]]; then
            clear
            onrepeat_create_subdomain

        elif [[ $new_sub == "ls" || $new_sub == "list" ]]; then
            list_of_domains

        elif [[ $new_sub == "dotnet" || $new_sub == "Dotnet" || $new_sub == "DOTNET" || $new_sub == "c#" ]]; then
            onrepeat_create_dotnet_subdomain
        
        elif [[ $new_sub == "ports" || $new_sub == "Ports" || $new_sub == "showports" || $new_sub == "PORTS" ]]; then
            list_of_domain_ports

        elif [[ $new_sub == "setports" || $new_sub == "Setports" || $new_sub == "set ports" || $new_sub == "set port" || $new_sub == "setport" ]]; then
            set_domain_ports

        elif [[ $new_sub == "commands" || $new_sub == "Commands" || $new_sub == "cmd" || $new_sub == "cmds" ]]; then
            list_of_commands

        elif [[ $new_sub == "back" || $new_sub == "menu" ]]; then
            menu

        else
            # Get user input on whether a directory is needed for subdomain
            printf "[*] Does your subdomain require a root directory: "
            read -r dir_answer

        fi
            if [[ $dir_answer == "YES" || $dir_answer == "yes" || $dir_answer == "y" ]]; then

                if [[ -d "/etc/apache2/sites-available/$new_sub${VAR2}" && -d "/var/www/$new_sub" ]]; then
                    echo ""
                    echo -e "\t [-] Domain already exists. Please enter new domain. [-]"
                    clear
                    onrepeat_create_subdomain

                else

                    echo ""
                    # Creating template to store in virtual host
                    echo -e "\t [+] Creating Virtual host configuration file for $new_sub..."
                    cp /home/subdomain_templates/template.conf /home/subdomain_templates/$new_sub${VAR2}

                    # Substitue user domain name for values placed in template
                    find /home/subdomain_templates/ -name $new_sub${VAR2} -exec sed -i "s|${VAR7}|${new_sub}|g" {} \;
                    echo -e "\t [+] Virtual host for subdomain: $new_sub Completed "

                    # Create Error and Access logs
                    echo -e "\t [+] Creating Access and Error logs for subdomain: $new_sub..."
                    > /var/log/apache2/$new_sub${VAR3}
                    > /var/log/apache2/$new_sub${VAR4}
                    echo -e "\t [+] Access and Error logs for subdomain : $new_sub Completed "

                    # Log completed virtual host in folder : /home/subdomain_templates/completed
                    mv /home/subdomain_templates/$new_sub${VAR2} /home/subdomain_templates/completed
                    echo -e "\t [+] Virtual host completed conf for subdomain successfully logged."

                    # Put conf file in apache2 ready to go live
                    cp /home/subdomain_templates/completed/$new_sub${VAR2} /etc/apache2/sites-available/
                    echo -e "\t [+] Subdomain virtual host conf successfully placed in Apache2"

                    # Create site directory for subdomain
                    mkdir /var/www/$new_sub
                    echo -e "\t [+] Directory for subdomain site : $new_sub successfully created."

                    echo ""
                    printf "[*] Would you like to enable site to go live? "
                    read -r user_live_decision_direct
                    if [[ $user_live_decision_direct == "yes" || $user_live_decision_direct == "y" || $user_live_decision_direct == "YES" || $user_live_decision_direct == "Yes" ]]; then

                        #a2ensite /etc/apache2/sites-available/$new_sub${VAR1}
                        a2ensite $new_sub${VAR1}

                        echo ""
                        echo ""
                        echo -e "\t <-------------------------------------------------------------------------------------------->"
                        echo -e "\t [*] Completed : Loading site onto server --> a2ensite $new_sub${VAR2} [+]"
                        echo -e "\t <-------------------------------------------------------------------------------------------->"

                        systemctl reload apache2

                        echo ""
                        echo ""
                        echo -e "\t <-------------------------------------------------------------------------------------------->"
                        echo -e "\t [*] Completed : Site Loadeded Successfully Completed --> YourDomain.cervg.com"
                        echo -e "\t <-------------------------------------------------------------------------------------------->"



                    elif [[ $user_live_decision_direct == "no" || $user_live_decision_direct == "n" || $user_live_decision_direct == "NO" || $user_live_decision_direct == "No" ]]; then

                        echo ""
                        echo ""
                        echo -e "\t <-------------------------------------------------------------------------------------------->"
                        echo -e "\t [*] Reminder : Enable site with command in directory location --> a2ensite $new_sub${VAR2} [*]"
                        echo -e "\t <-------------------------------------------------------------------------------------------->"

                    else

                        echo ""
                        echo ""
                        echo -e "\t <----------------------------------------------------->"
                        echo -e "\t [*] Incorrect answer. Proceeding without live decision."
                        echo -e "\t <----------------------------------------------------->"
                    fi

                    completed_sub_domain_with_directory

                fi

            elif [[ $dir_answer == "back" || $dir_answer == "menu" || $dir_answer == "BACK" ]]; then
                onrepeat_create_subdomain

            else

                echo ""
                # Creating template to store in virtual host
                echo -e "\t [+] Creating Virtual host configuration file for $new_sub..."
                cp /home/subdomain_templates/template.conf /home/subdomain_templates/$new_sub${VAR2}

                # Substitue user domain name for values placed in template
                find /home/subdomain_templates/ -name $new_sub${VAR2} -exec sed -i "s|${VAR7}|${new_sub}|g" {} \;
                echo -e "\t [+] Virtual host for subdomain: $new_sub Completed "

                # Create Error and Access logs
                echo -e "\t [+] Creating Access and Error logs for subdomain: $new_sub..."
                > /var/log/apache2/$new_sub${VAR3}
                > /var/log/apache2/$new_sub${VAR4}
                echo -e "\t [+] Access and Error logs for subdomain : $new_sub Completed "

                # Log completed virtual host in folder : /home/subdomain_templates/completed
                mv /home/subdomain_templates/$new_sub${VAR2} /home/subdomain_templates/completed
                echo -e "\t [+] Virtual host completed conf for subdomain successfully logged."

                # Put conf file in apache2 ready to go live
                cp /home/subdomain_templates/completed/$new_sub${VAR2} /etc/apache2/sites-available/
                echo -e "\t [+] Subdomain virtual host conf successfully placed in Apache2"
                echo ""

                printf "[*] Would you like to enable site to go live? "
                read -r user_live_decision
                if [[ $user_live_decision == "yes" || $user_live_decision == "y" || $user_live_decision == "YES" || $user_live_decision == "Yes" ]]; then

                    a2ensite $new_sub${VAR1}

                elif [[ $user_live_decision == "no" || $user_live_decision == "n" || $user_live_decision == "NO" || $user_live_decision == "No" ]]; then

                    echo ""
                    echo ""
                    echo -e "\t <-------------------------------------------------------------------------------------------->"
                    echo -e "\t [*] Reminder : Enable site with command in directory location --> a2ensite $new_sub${VAR1} [*]"
                    echo -e "\t <-------------------------------------------------------------------------------------------->"

                else

                    echo ""
                    echo ""
                    echo -e "\t <----------------------------------------------------->"
                    echo -e "\t [*] Incorrect answer. Proceeding without live decision."
                    echo -e "\t <----------------------------------------------------->"

                fi

                completed_sub_domain_without_directory

            fi
    }

    function list_of_domain_ports() {
        echo ""
        echo -e "\t <------------------------------------------------------->"
        echo -e "\t                   [*] Domain Ports [*]"
        echo -e "\t <------------------------------------------------------->"
        grep -i "pass" ${VARDIR}*${VAR2}
        echo ""
        onrepeat_create_subdomain
    }

    function list_of_commands() {
        echo ""
        echo -e "\t <------------------------------------------------------->"
        echo -e "\t                   [*] List of Commands [*]"
        echo -e "\t <------------------------------------------------------->"
        echo -e "\t [*] ls           : Description --> Display list of available domains currently active/inactive [*]"
        echo -e "\t [*] ports        : Description --> Display list of currently used ports by dotnet domains [*]"
        echo -e "\t [*] dotnet ports : Description --> Set port of dotnet domains with Kestrel server [*]"
        echo -e "\t [*] dotnet domain: Description --> Display list of current dotnet domains [*]"
        echo -e "\t [*] menu         : Description --> Go to main menu [*]"
        echo -e "\t [*] exit         : Description --> Exit program [*]"
        echo -e "\t [*] quit         : Description --> Quit program [*]"
        echo ""
        onrepeat_create_subdomain
    }

    function set_domain_ports() {
        echo ""
        grep -i "pass" ${VARDIR2}
        echo ""
        printf "\t [*] Please enter existing port number in config file: "
        read -r existing_port
        printf "\t [*] Please enter your new dotnet domain port number: "
        read -r setting_port
        echo -e "\t [*] Setting new dotnet domain port in configuration file"
        find ${VARDIR3} -name ${DOTNETCONFIG} -exec sed -i "s/${existing_port}/${setting_port}/g" {} \;
        echo -e "\t [*] Port successfully changed.."
        echo ""
        grep -i "pass" ${VARDIR2}
        onrepeat_create_subdomain

    }

    function onrepeat_create_dotnet_subdomain() {

        echo ""
        echo -e "\t <------------ !! DO NOT ENTER FULL DOMAIN !! ------------> "
        echo -e "\t [*] Example: yourdomain.cervg.com |||| Only: yourdomain [*]"
        echo -e "\t <--------------------------------------------------------> "
        echo ""

        # Get user input for name of new subdomain
        printf "[*] Please enter name for your new [C# -> dotnet] subdomain: "
        read -r new_sub
        VAR7=$"sub"
        DOT1=$"kestrel-"
        DOT2=$".service"
        DOT3=$"dotnet"

        if [[ $new_sub == "clear" || $new_sub == "reset" ]]; then
            clear
            onrepeat_create_subdomain

        elif [[ $new_sub == "ls" || $new_sub == "list" ]]; then
            list_of_domains

        elif [[ $new_sub == "back" || $new_sub == "menu" ]]; then
            menu

        else
            # Get user input on whether a directory is needed for subdomain
            printf "[*] Does your [C# -> dotnet] subdomain require a root directory: "
            read -r dir_answer

        fi
            if [[ $dir_answer == "YES" || $dir_answer == "yes" || $dir_answer == "y" ]]; then

                if [[ -d "/etc/apache2/sites-available/$new_sub${VAR2}" && -d "/var/www/$new_sub" ]]; then
                    echo ""
                    echo -e "\t [-] Domain already exists. Please enter new domain. [-]"
                    clear
                    onrepeat_create_dotnet_subdomain

                else

                    echo ""
                    # Creating template to store in virtual host
                    echo -e "\t [+] Creating Virtual host configuration file for $new_sub..."
                    cp -v /home/subdomain_templates/$DOT3${VAR2} /home/subdomain_templates/$new_sub${VAR2}

                    # Substitue user domain name for values placed in template
                    find /home/subdomain_templates/ -name $new_sub${VAR2} -exec sed -i "s|${VAR7}|${new_sub}|g" {} \;
                    echo -e "\t [+] Virtual host for subdomain: $new_sub Completed "

                    # Creating Kestrel-domain-service for dotnet program
                    echo -e "\t\t [+] Creating Kestrel-Apache domain service for $new_sub..."
                    cp /home/subdomain_templates/kestrel-sub.service /home/subdomain_templates/$DOT1$new_sub${DOT2}

                    # Substitue variable names in service template for dotnet domain specific user-selected names
                    echo -e "\t\t [+] Completing Kestrel-Apache domain service template for $new_sub..."
                    find /home/subdomain_templates/ -name $DOT1$new_sub${DOT2} -exec sed -i "s|${VAR7}|${new_sub}|g" {} \;

                    # Registering dotnet service with systemd to create symlink between kestrel and apache2
                    echo -e "\t\t [+] Creating symlink service between Kestrel and Apache in Systemd"
                    cp /home/subdomain_templates/$DOT1$new_sub${DOT2} /etc/systemd/system/

                    # Complete dotnet service symlink service
                    systemctl enable $DOT1$new_sub${DOT2}
                    systemctl start $DOT1$new_sub${DOT2}
                    systemctl reload apache2
                    # systemctl status $DOT1$new_sub${DOT2}
                    echo -e "\t\t [+] Service symlink succesfully completed"

                    # Create Error and Access logs
                    echo -e "\t [+] Creating Access and Error logs for subdomain: $new_sub..."
                    > /var/log/apache2/$new_sub${VAR3}
                    > /var/log/apache2/$new_sub${VAR4}
                    echo -e "\t [+] Access and Error logs for subdomain : $new_sub Completed "

                    # Log completed virtual host in folder : /home/subdomain_templates/completed
                    mv /home/subdomain_templates/$new_sub${VAR2} /home/subdomain_templates/completed
                    echo -e "\t [+] Virtual host completed conf for subdomain successfully logged."

                    # Move completed service as backup in folder : /home/subdomain_templates/completed_services
                    mv /home/subdomain_templates/$DOT1$new_sub${DOT2} /home/subdomain_templates/completed_services
                    echo -e "\t [+] Service Backup successfully stored in completed services directory"

                    # Put conf file in apache2 ready to go live
                    cp /home/subdomain_templates/completed/$new_sub${VAR2} /etc/apache2/sites-available/
                    echo -e "\t [+] Subdomain virtual host conf successfully placed in Apache2"

                    # Create site directory for subdomain
                    mkdir /var/www/$new_sub
                    echo -e "\t [+] Directory for subdomain site : $new_sub successfully created."

                    echo ""
                    printf "[*] Would you like to enable site to go live? "
                    read -r user_live_decision_direct
                    if [[ $user_live_decision_direct == "yes" || $user_live_decision_direct == "y" || $user_live_decision_direct == "YES" || $user_live_decision_direct == "Yes" ]]; then

                        #a2ensite /etc/apache2/sites-available/$new_sub${VAR1}
                        a2ensite $new_sub${VAR1}

                        echo ""
                        echo ""
                        echo -e "\t <-------------------------------------------------------------------------------------------->"
                        echo -e "\t [*] Completed : Loading site onto server --> a2ensite $new_sub${VAR2} [+]"
                        echo -e "\t <-------------------------------------------------------------------------------------------->"

                        systemctl reload apache2

                        echo ""
                        echo ""
                        echo -e "\t <-------------------------------------------------------------------------------------------->"
                        echo -e "\t [*] Completed : Site Loadeded Successfully Completed --> YourDomain.cervg.com"
                        echo -e "\t <-------------------------------------------------------------------------------------------->"
                        deploy_dotnet_app

                    elif [[ $user_live_decision_direct == "no" || $user_live_decision_direct == "n" || $user_live_decision_direct == "NO" || $user_live_decision_direct == "No" ]]; then

                        echo ""
                        echo ""
                        echo -e "\t <-------------------------------------------------------------------------------------------->"
                        echo -e "\t [*] Reminder : Enable site with command in directory location --> a2ensite $new_sub${VAR2} [*]"
                        echo -e "\t <-------------------------------------------------------------------------------------------->"

                    else

                        echo ""
                        echo ""
                        echo -e "\t <----------------------------------------------------->"
                        echo -e "\t [*] Incorrect answer. Proceeding without live decision."
                        echo -e "\t <----------------------------------------------------->"
                    fi


                    completed_sub_domain_with_directory

                fi

            elif [[ $dir_answer == "back" || $dir_answer == "menu" || $dir_answer == "BACK" ]]; then
                onrepeat_create_subdomain

            else

                echo ""
                # Creating template to store in virtual host
                echo -e "\t [+] Creating Virtual host configuration file for $new_sub..."
                cp /home/subdomain_templates/$DOT3${VAR2} /home/subdomain_templates/$new_sub${VAR2}

                # Substitue user domain name for values placed in template
                find /home/subdomain_templates/ -name $new_sub${VAR2} -exec sed -i "s|${VAR7}|${new_sub}|g" {} \;
                echo -e "\t [+] Virtual host for subdomain: $new_sub Completed "

                # Creating Kestrel-domain-service for dotnet program
                echo -e "\t\t [+] Creating Kestrel-Apache domain service for $new_sub..."
                cp /home/subdomain_templates/kestrel-sub.service /home/subdomain_templates/$DOT1$new_sub${DOT2}

                # Substitue variable names in service template for dotnet domain specific user-selected names
                echo -e "\t\t [+] Completing Kestrel-Apache domain service template for $new_sub..."
                find /home/subdomain_templates/ -name $DOT1$new_sub${DOT2} -exec sed -i "s|${VAR7}|${new_sub}|g" {} \;

                # Registering dotnet service with systemd to create symlink between kestrel and apache2
                echo -e "\t\t [+] Creating symlink service between Kestrel and Apache in Systemd"
                cp /home/subdomain_templates/$DOT1$new_sub${DOT2} /etc/systemd/system/

                # Complete dotnet service symlink service
                systemctl enable $DOT1$new_sub${DOT2}
                systemctl start $DOT1$new_sub${DOT2}
                systemctl reload apache2
                # systemctl status $DOT1$new_sub${DOT2}
                echo -e "\t\t [+] Service symlink succesfully completed"

                # Create Error and Access logs
                echo -e "\t [+] Creating Access and Error logs for subdomain: $new_sub..."
                > /var/log/apache2/$new_sub${VAR3}
                > /var/log/apache2/$new_sub${VAR4}
                echo -e "\t [+] Access and Error logs for subdomain : $new_sub Completed "

                # Log completed virtual host in folder : /home/subdomain_templates/completed
                mv /home/subdomain_templates/$new_sub${VAR2} /home/subdomain_templates/completed
                echo -e "\t [+] Virtual host completed conf for subdomain successfully logged."
                
                # Move completed service as backup in folder : /home/subdomain_templates/completed_services
                mv /home/subdomain_templates/$DOT1$new_sub${DOT2} /home/subdomain_templates/completed_services
                echo -e "\t [+] Service Backup successfully stored in completed services directory"

                # Put conf file in apache2 ready to go live
                cp /home/subdomain_templates/completed/$new_sub${VAR2} /etc/apache2/sites-available/
                echo -e "\t [+] Subdomain virtual host conf successfully placed in Apache2"
                echo ""

                printf "[*] Would you like to enable site to go live? "
                read -r user_live_decision
                if [[ $user_live_decision == "yes" || $user_live_decision == "y" || $user_live_decision == "YES" || $user_live_decision == "Yes" ]]; then

                    a2ensite $new_sub${VAR1}

                elif [[ $user_live_decision == "no" || $user_live_decision == "n" || $user_live_decision == "NO" || $user_live_decision == "No" ]]; then

                    echo ""
                    echo ""
                    echo -e "\t <-------------------------------------------------------------------------------------------->"
                    echo -e "\t [*] Reminder : Enable site with command in directory location --> a2ensite $new_sub${VAR1} [*]"
                    echo -e "\t <-------------------------------------------------------------------------------------------->"

                else

                    echo ""
                    echo ""
                    echo -e "\t <----------------------------------------------------->"
                    echo -e "\t [*] Incorrect answer. Proceeding without live decision."
                    echo -e "\t <----------------------------------------------------->"

                fi

                completed_sub_domain_without_directory

            fi
    }


    function completed_sub_domain_with_directory() {

        echo ""
        echo -e "\t ######################################## ACTION COMPLETED ###########################################"
        echo -e "\t ########## Subdomain : $new_sub "
        echo -e "\t ########## Directory : /var/www/$new_sub"
        echo -e "\t ########## Virtual H : /etc/apache2/sites-available/$new_sub$VAR2"
        echo -e "\t ########## REMINDER  : Please Create SSL with : letsencrypt"
        echo -e "\t ######################################## ACTION COMPLETED ###########################################"
        echo ""
        menu
    }


    function completed_sub_domain_without_directory() {

        echo ""
        echo -e "\t ######################################## ACTION COMPLETED ###########################################"
        echo -e "\t ########## Subdomain : $new_sub"
        echo -e "\t ########## Directory : NONE"
        echo -e "\t ########## Virtual H : /etc/apache2/sites-available/$new_sub$VAR2 "
        echo -e "\t ########## REMINDER  : Please Create SSL with : letsencrypt "
        echo -e "\t ######################################## ACTION COMPLETED ###########################################"
        echo ""
        menu
    }


    echo ""
    echo -e "\t [*] Subdomain will end with: (*).cervg.com"
    echo -e "\t [*] Example: subdomain.cervg.com <--- will be the subdomain."
    echo -e "\t [*] Below is the list subdomains already created."
    list_of_domains


}

function remove_subdomain() {

    REM1=$".cervg.com.conf"
    REM2=$".cervg.com*"
    REM3=$"_error.log"
    REM3=$"_access.log"


    function list_of_domains_share() {

        echo ""
        echo "############ Domain List ############"
        awk 'BEGIN{ print "\nObtaining List ...\n"} { print FILENAME; nextfile }END{ print "\n... List Completed\n"} ' /etc/apache2/sites-available/*.cervg.com.conf
        echo "#####################################"
        echo ""

    }

    list_of_domains_share


    printf "[+] Please enter subdomain you want to remove: "
    read -r subd_remove
    REM5=$"$subd_remove${REM1}"
    REMKESTRELFILE=$"kestrel-${subd_remove}.service"

    if [[ -f "/home/subdomain_templates/completed/$REM5" && -f "/etc/apache2/sites-available/$REM5" ]]; then
        echo ""

	    # Disable live site
        echo -e "\t [+] Disabling site... "
	    a2dissite $subd_remove${REM2}

	    # Reload Apahce server
        echo -e "\t [+] Restarting web server... "
	    systemctl reload apache2

        # Remove Error and Access logs
        rm /var/log/apache2/$subd_remove*
	    rm -r /var/www/$subd_remove

        #rm /var/log/apache2/$subd_remove${REM4}
        echo -e "\t [+] Access and Error logs for subdomain removed... "

        # Remove virtual host in folder : /home/subdomain_templates/completed
        rm /home/subdomain_templates/completed/$subd_remove${REM1}
        echo -e "\t [+] Subdomain virtual host conf removed from domain folder..."

        # Remove conf from apache2
        rm /etc/apache2/sites-available/$subd_remove${REM1}
        echo -e "\t [+] Subdomain virtual host conf removed from Apache2"
        if [[ -f "/etc/systemd/system/${REMKESTRELFILE}" ]]; then
            echo -e "\t [+] Kestrel service found.."
            rm /etc/systemd/system/${REMKESTRELFILE}
            rm /etc/systemd/system/multi-user.target.wants/${REMKESTRELFILE}
            echo -e "\t [+] Kestrel service ${REMKESTRELFILE} removed..."
            echo ""
            echo -e "\t ################# Action Completed #################"
            menu
        else
            echo ""
            echo -e "\t ################# Action Completed #################"
            menu
        fi

    elif [[ $subd_remove == "clear" || $subd_remove == "reset" ]]; then
        clear
        remove_subdomain

    elif [[ $subd_remove == "ls" || $subd_remove == "list" ]]; then
        remove_subdomain

    elif [[ $subd_remove == "back" || $subd_remove == "menu" ]]; then
        menu

    else
        echo ""
        echo -e "\t [-] Invalid operation : Please try again. [-]"
        remove_subdomain

   fi

}

menu
