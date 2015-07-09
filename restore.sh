#!/bin/bash

restore_config=$1
fdisk_cmd="busybox fdisk"
bootsize="+128M"

source $restore_config
if ! source $restore_config &> /dev/null
then
  echo "No restore config found."
  exit 1
fi

restore_path=${backup_path}/restore

echo "Restorepath: ${restore_path}"

if ! which duplicity &> /dev/null 
then
  echo "Please install duplicity."
  exit 1
fi

if ! [ -d $backup_path ]
then
  echo "Backup path '$backup_path' not found"
  exit 1
fi

if ! ( [ -d $restore_path ] || mkdir $restore_path &> /dev/null )
then
  echo "Can't create directory ${restore_path}. Quit."
  exit 1
fi

if ! source ua_code.sh &> /dev/null
then
  echo "ua_code.sh not found"
  exit 1
fi

if ! which $fdisk_cmd &> /dev/null
then
  echo "fdisk_cmd '${fdisk_cmd}' not found"
  exit 1
fi

echo "Creating root / boot partitions.."
create_partitions

echo "Creating filesystems.. "
create_filesystem_options
create_filesystems

echo -n "Mounting new filesystems... "

if ! mount $rootpartition $restore_path -o $rootfs_install_mount_options
then
  echo "Unable to mount rootpartition"
  exit 1
fi


if ! ( mkdir $restore_path/boot && mount $bootpartition $restore_path/boot )
then
  echo "Unable to mount bootpartition"
  exit 1
fi

echo "done!"

time duplicity --force --no-encryption file://$backup_path/root $restore_path
time duplicity --force --no-encryption file://$backup_path/boot $restore_path/boot

mkdir $restore_path/{dev,proc,sys,selinux,mnt,media,run,tmp}

umount $restore_path/boot
umount $restore_path
