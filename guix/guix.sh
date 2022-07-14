#!/usr/bin/env bash

#https://osboot.org/docs/gnulinux/guix.html

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

cryptsetup luksFormat --type luks2 /dev/sda3
cryptsetup open /dev/sda3 cryptroot

# format partitions and turn on swap
# mkfs.ext2 /dev/sda1
mkfs.ext4 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/mapper/cryptroot

# mount root and start store
mount /dev/mapper/cryptroot /mnt
herd start cow-store /mnt
