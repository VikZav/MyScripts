#!/bin/bash

# перевіряємо чи передані перемінні анрументами, якщо ні, використовуємо внутрішні перемінні;
if [ -z "$1" ]
    then
        domain=your_domain_name
    else
        domain=$1
fi

if [ -z "$2" ]
    then
        ipaddress=your_internal_ip_adress
    else
        ipaddress=$2
fi

#  створюємо файл конфіга для апач проксі
{
echo "<VirtualHost *:80>"
echo "          ServerName  ${domain}"
echo "          ProxyPreserveHost On"
echo "          ProxyPass / http://${ipaddress}/"
echo "          ProxyPassReverse / http://${ipaddress}/"
echo "#SSLProxyEngine on"
echo "</VirtualHost>"
} > /etc/apache2/sites-available/${domain}.conf

# сімлінкуємо його в папку з конфігами
ln -s /etc/apache2/sites-available/${domain}.conf /etc/apache2/sites-enabled/${domain}.conf

#  рестартуємо апач
service apache2 reload
