#!/usr/bin/env bash

# bios/mbr
# NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
# sda      8:0    0 68.2G  0 disk
# ├─sda1   8:1    0   99M  0 part
# ├─sda2   8:2    0  3.9G  0 part
# └─sda3   8:3    0 64.2G  0 part
parted /dev/sda mklabel msdos
parted /dev/sda mkpart primary ext3 1MiB 100MiB
parted /dev/sda set 1 boot on
parted /dev/sda mkpart primary linux-swap 100MiB 4GiB
parted /dev/sda mkpart primary ext3 4GiB 100%

# format partitions and turn on swap
mkfs.ext2 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 -L root /dev/sda3

# mount root and start store
mount /dev/sda3 /mnt
herd start cow-store /mnt

guix pull --substitute-urls=https://bordeaux.guix.gnu.org
bash -c "guix install git --substitute-urls=https://bordeaux.guix.gnu.org"
cd /mnt
bash -c "git clone https://github.com/KefirOnPremise/deprecated.git"
guix pull \
     -C ./deprecated/etc/channels \
     --disable-authentication \
     --allow-downgrades \
     --substitute-urls=https://bordeaux.guix.gnu.org
bash \
    -c "
guix system init /mnt/deprecated/etc/sysconfs/imp /mnt \
     --substitute-urls=https://bordeaux.guix.gnu.org
"
