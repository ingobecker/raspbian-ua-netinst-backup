#!/bin/bash

backup_path=$1
stop_services="postgresql"

if [ ! -d "$backup_path" ]; then
  echo "non existing path given" 
  exit 1
fi

echo "backing up"

for service in $stop_services; do
  service $service stop
done

if ! ( [ -d $backup_path/tmp ] || mkdir  $backup_path/tmp > /dev/null )
then
  echo "Unable to create tmp directory '${backup_path}/tmp'"
fi

backup_dirs="bin etc home initrd.img lib opt root sbin srv usr var vmlinuz"
duplicity_includes=""

for fn in $backup_dirs; do
  duplicity_includes="${duplicity_includes} --include /${fn}"
done

time duplicity --full-if-older-than 1M --no-encryption --tempdir $backup_path/tmp --exclude /var/cach/apt/archives $duplicity_includes --exclude '**' / file:///$backup_path/root >> $backup_path/root.log
time duplicity --full-if-older-than 1M --no-encryption --tempdir $backup_path/tmp /boot file:///$backup_path/boot >> $backup_path/boot.log

for service in $stop_services; do
  service $service start
done
