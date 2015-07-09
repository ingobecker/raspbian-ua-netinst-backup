#!/bin/bash

create_partitions()
{
  if [ "$rootdev" = "$bootdev" ]; then
    echo -n "Applying new partition table... "
    dd if=/dev/zero of=$bootdev bs=512 count=1 &>/dev/null
    fdisk $bootdev &>/dev/null <<EOF
n
p
1

$bootsize
t
b
n
p
2

$rootsize
w
EOF
    echo "OK"
  else
    echo -n "Applying new partition table for $bootdev... "
    dd if=/dev/zero of=$bootdev bs=512 count=1 &>/dev/null
    fdisk $bootdev &>/dev/null <<EOF
n
p
1

$bootsize
t
b
w
EOF
echo "OK"
echo -n "Applying new partition table for $rootdev... "
dd if=/dev/zero of=$rootdev bs=512 count=1 &>/dev/null
fdisk $rootdev &>/dev/null <<EOF
n
p
1

$rootsize
w
EOF
    echo "OK"
  fi

}

create_filesystems()
{
  
  echo -n "Initializing /boot as vfat... "
  mkfs.vfat $bootpartition || fail
  echo "OK"
  
  echo -n "Initializing / as $rootfstype... "
  mkfs.$rootfstype $rootfs_mkfs_options $rootpartition &>/dev/null || fail
  echo "OK"
}

create_filesystem_options()
{
  case "$rootfstype" in
    "btrfs")
      kernel_module=true
      rootfs_mkfs_options=${rootfs_mkfs_options:-'-f'}
      rootfs_install_mount_options=${rootfs_install_mount_options:-'noatime'}
      rootfs_mount_options=${rootfs_mount_options:-'noatime'}
      ;;
    "ext4")
      kernel_module=true rootfs_mkfs_options=${rootfs_mkfs_options:-''}
      rootfs_install_mount_options=${rootfs_install_mount_options:-'noatime,data=writeback,nobarrier,noinit_itable'}
      rootfs_mount_options=${rootfs_mount_options:-'errors=remount-ro,noatime'}
      ;;
    "f2fs")
      kernel_module=true
      rootfs_mkfs_options=${rootfs_mkfs_options:-''}
      rootfs_install_mount_options=${rootfs_install_mount_options:-'noatime'}
      rootfs_mount_options=${rootfs_mount_options:-'noatime'}
      ;;
  esac
}

fail()
{
  echo "Failed to restore backup."
}
