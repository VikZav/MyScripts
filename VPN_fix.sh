#!/bin/bash

route_string=`route -n | sed -n 3p`
vpn_gw=`route -n | sed -n 3p | awk '{print$2}'`


if [[ $route_string == *"tun1"* ]]; then
    echo "VPN is on, fixing it ..."
    sleep 3
    route del -net 0.0.0.0 gw $vpn_gw netmask 0.0.0.0 dev tun1
    echo -e "\nroute del -net 0.0.0.0 gw $vpn_gw netmask 0.0.0.0 dev tun1\n" >> /etc/network/if-up.d/openvpn
    echo "Done, you can start using internet!"
    else 
    echo "VPN is not ON or already fixed"
fi 
