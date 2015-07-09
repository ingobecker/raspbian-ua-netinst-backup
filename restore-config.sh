backup_path=/mnt/sd/raspi2
bootdev=/dev/sdc
bootpartition=/dev/sdc1

rootdev=/dev/sdc
rootpartition=/dev/sdc2
rootfstype=ext4
rootfs_mkfs_options="-O^has_journal -E stride=2,stripe-width=2048 -b 4096"

fdisk_cmd=fdisk
