#!/bin/bash

# перевіряємо чи передані перемінні анрументами, якщо ні, використовуємо внутрішні перемінні;
if [ -z "$1" ]
    then
	domain=new_domain
    else
	domain=$1
fi

if [ -z "$2" ]
    then
	ipaddress=internal_ip_adress
    else
	ipaddress=$2
fi

#  створюємо файл конфіга для апач проксі
{
echo "<VirtualHost *:80>"
echo "		ServerName  ${domain}"
echo "		ProxyPreserveHost On"
echo "		ProxyPass / http://${ipaddress}/"
echo "		ProxyPassReverse / http://${ipaddress}/"
echo "#SSLProxyEngine on"
echo "</VirtualHost>"
} > /etc/apache2/sites-available/${domain}.conf

# сімлінкуємо його в папку з конфігами
ln -s /etc/apache2/sites-available/${domain}.conf /etc/apache2/sites-enabled/${domain}.conf

#  рестартуємо апач
service apache2 reload

# генеруємо та встановлюємо серетфікат:
certbot run -d ${domain} --apache -n

#сімлінкуємо серетфікати у папку для маунт шарінга у контейнери і на всякий випадок переназначаємо права на неї:
cp -Lur /etc/letsencrypt/live /mnt/
chown -R nobody:nogroup /mnt/
chmod -R 755 /mnt/

#визначаємо номер контейнера із ip адреса:
ctnumber=`echo ${ipaddress} | cut -d . -f 4`
#монтуємо папку з серетфікатами у контейнер:
pct set ${ctnumber} -mp0 /mnt/live/${domain},mp=/mnt/${domain},ro=1

#прокидуємо порт для ssh  доступу:
iptables -t nat -A PREROUTING -i eno1 -p tcp -m tcp --dport ${ctnumber} -j DNAT --to-destination ${ipaddress}:22

#=========================================================
#=======================перевірки=========================
#=========================================================

#перевірка чи є проксі конфіг для апача:
if [ `apache2ctl -S | grep ${domain} | wc -l` = 0 ]
    then
	echo "no domain"
    else
	echo -e "Apache proxy is \e[5m\e[32m[OK]\e[0m\e[25m --->" `apache2ctl -S | grep ${domain}`
fi

#перевірка чи є сертефікат для домена у папці для подальшого монтування у контейнери:

if [ -d /mnt/live/${domain}  ]
    then
echo -e "Sertificate is \e[5m\e[32m[OK]\e[0m\e[25m ---> /mnt/live/"${domain}
    else
echo "No sertificate in /mnt/live/"${domain}
fi

#перевірка чи є потрібний контейнер:

if [ `pct list | grep ${domain} | wc -l` -le 0 ]
    then
	echo "No container found"
    else
	echo -e "Container is \e[5m\e[32m[OK]\e[0m\e[25m ---> "`pct list | grep ${domain}`
fi

#перевірка чи є правило для ssh  доступу у контейнер:
if [ `iptables -t nat -L | grep 22${ctnumber} | wc -l` -le 0 ]
    then
	echo "No IPTABLE rule found"
    else
	echo -e "IPTABLES rule is \e[5m\e[32m[OK]\e[0m\e[25m ---> "`iptables -t nat -L | grep 22${ctnumber}`
fi
