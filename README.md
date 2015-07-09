# raspbian-ua-netinst-backup
This script assists you in creating backups of your raspberry pi installation created with the [raspbian-ua-netinst](https://github.com/debian-pi/raspbian-ua-netinst) script. By default the script will reassmble a fully bootable sd card from the created backup. This can be useful to recover youe system in case you fucked up your installation, your sd card or your raspi. Incremental backups are used in order to use as little space as possible. You can easily use this script to [align and tune](#Align and tune sd partitions) your sd card partitions as well.

## Creating a backup

To create a backup, log into your raspbian, clone this repo and run `./backup.sh <backup-path>`. To create offsite-backups it makes sense to mount a USB thumbdrive or something similar to <backup-path>. After `backup.sh` finished its job an initial full backup of your raspbian installation was created. Running `./backup.sh` with the same backup-path will create incremental backups unless the last full backup has been created longer than one month ago.

## Restoring a backup

Mount the device which contains your previously created backups to a location `<backup-path>`. In order to restore to your backup, create a restore-configuration file `my-restore-config.sh`:

```bash
# the path containen the created backups
backup_path=/mnt/backup

# the device the script will restore your bootpartition to
# (usally a sd card)
bootdev=/dev/sdc
# the bootpartition which will be created by the backup script
bootpartition=/dev/sdc1

# the device the script will restore your rootpartition to
rootdev=/dev/sdc
# the rootpartition which will be created by the backup script
rootpartition=/dev/sdc2
 
rootfstype=ext4
rootfs_mkfs_options=^has_journal -E stride=2,stripe-width=2048 -b 4096

# defaults to 'busybox fdisk'
fdisk_cmd=busybox fdisk

```

Most of the options above are the same as those from the `installer-config.txt` used by the raspbian-ua-netinst script. To restore the partition table of your raspbian installation you will have to install busybox as the raspbian-ua-netinst uses the fdisk versions form busybox.

Run `./restore <my-restore-config.sh>`.


## Align and tune sd partitions

The raspbian-ua-netinst script doesn't create aligned sd card partitions. This will reduce the lifetime and performance of your sd card. To align an installation afterwards, simply create a backup as described above. Change the `fdisk_cmd` to `fdisk` of your restore config file. This will use the fdisk version of your host system, which will align the sd card by default. Restore the created backup. Your should be aligned now.

**Caution:** The default units which are used by your host version of fdisk differ from the ones used by the fdisk version used in raspbian-ua-netinst. This means that if you don't convert the size options of your restore-configuration it is more than likely that you will end up with different sized restored partitions. Check out the manpage for fdisk and busybox for more information.
