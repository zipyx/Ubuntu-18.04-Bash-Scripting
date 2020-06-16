#!/bin/bash

# Run VPN script to retrieve users
pivpn -c > /home/phano/vpn_users/users_online.txt
pivpn -l > /home/phano/vpn_users/user_vpn_list.txt
