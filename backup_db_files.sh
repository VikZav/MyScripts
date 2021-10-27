#!/bin/bash

#Вказуємо папку для бекапу 
backup_dir="/srv/files_backups/"
#додаємо дату бекапу до назви файла
backup_date=`date +%d-%m-%Y`
#Зберігати копіїї стількох днів:
number_of_days=10

# бекап постгреса

#визначаємо бази для бекапу:
databases=`psql -l -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`
for i in $databases; do  if [ "$i" = "project_production" ]; then
    echo Dumping $i to $backup_dir$i\_$backup_date.dump
    pg_dump $i > $backup_dir$i\_$backup_date.dump
    tar --remove-files -cvzf $backup_dir$i\_$backup_date.tar.gz $backup_dir$i\_$backup_date.dump
fi
done

# бекапимо базу з докера:
docker exec -t 5255606c73d4 pg_dump -c -U project_catering_db_user project-katering_production > $backup_dir$i\_$backup_date.project-katering_production.dump

# архівуємо файли сайту:
/bin/tar -h -czf $backup_dir/$backup_date.project.tar.gz /home/deployer/apps/project/current
# картинки кейтерінга
/bin/tar -h -czf $backup_dir/$backup_date.project-catering.tar.gz /home/deployer/apps/catering/project-catering/storage


# архівуємо файли nginx:
/bin/tar -h -czf $backup_dir/$backup_date.nginx.tar.gz /etc/nginx

#видаляємо старі бекапи
find $backup_dir -type f -prune -mtime +$number_of_days -exec rm -f {} \;

# сінхронізуємо файли архівної директорії з віддаленим сховищем:
rsync --recursive --delete-after --progress -a /srv/files_backups deployer@200.180.200.500:project_family_backups
