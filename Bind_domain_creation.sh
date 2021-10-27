#!/bin/bash

# вказуємо домен та його іпку:

domain=new_domain
ip_internal=10.0.0.160
ip_external=100.200.300.200




# шукаємо та виділяємо серійний номер з першого файла:
old_serial=`grep serial domains.live | awk '{print $1}'`
# збільшуємо серійний номер на 1:
new_serial=`expr ${old_serial} + 1`

# здійснюємо перевірку на наявність домена у першому файлі:

if [ `grep ${domain} domains.live | wc -l` -le 0 ]

	then 
	    echo "${domain}		A	${ip_external}" >> domains.live   # дописуємо домен якшо не знаходимо його у списку
	    sed -i "s/${old_serial}/${new_serial}/g" domains.live                            # збільшуємо серійник на 1
	    echo "addind ${domain} to domains.live"					  # виводимо повідомлення про успеіше додавання домена
	else 
	    echo "${domain} already in the domains.live"				  # виводимо повідомлення про те що домен вже у списку.
fi

# шукаємо та збільшуємо серійний номер з другого  файла:
old_serial_int=`grep serial domains.live_int | awk '{print $1}'`
new_serial_int=`expr ${old_serial_int} + 1`


if [ `grep ${domain} domains.live_int | wc -l` -le 0 ]

	then 
	    echo "${domain}			A	${ip_internal}" >> domains.live_int   # дописуємо домен якшо не знаходимо його у списку
	    sed -i "s/${old_serial_int}/${new_serial_int}/g" domains.live_int                            # збільшуємо серійник на 1
	    echo "addind ${domain} to domains.live_int"					 # виводимо повідомлення про успеіше додавання домена
	else 
	    echo "${domain} already in the domains.live_int"				# виводимо повідомлення про те що домен вже у списку.

fi

# рестарт бінд сервіс
/etc/init.d/bind9 restart

# ретрансфер змін до слейва на sun.domains.net
ssh v.zavadskiy@sun.domains.net "sudo -S /etc/bind/retransfer"
