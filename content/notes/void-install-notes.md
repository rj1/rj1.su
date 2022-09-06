---
title: void linux installation notes
date: "2022-07-08"
---

install information:
- luks encrypted
- ext4 filesystem
- no lvm
- chroot install (https://docs.voidlinux.org/installation/guides/chroot.html)

# login

root:voidlinux

# interactive shell

```shell
bash
```

# create partition table

| partition | size | code | fs |
-------------------|-----------|------|------|
| boot (/dev/sda1) | 512 MiB  | ef00 | efi  |
| root (/dev/sda2) | the rest | 8300 | ext4 |

# create filesystems

```shell
cryptsetup luksFormat /dev/sda2
cryptsetup open /dev/sda2 cryptroot
mkfs.ext4 /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

mkfs.fat -F32 /dev/sda1
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```

# mount linux system

```shell
mkdir /mnt/dev && mount --rbind /dev /mnt/dev
mkdir /mnt/proc && mount --rbind /proc /mnt/proc
mkdir /mnt/sys && mount --rbind /sys /mnt/sys
```

or

```shell
for d in dev proc sys; do mkdir /mnt/$d && mount --rbind /$d /mnt/$d; done
```

# install void base-system

```shell
xbps-install -Sy -R https://repo-fi.voidlinux.org/current -r /mnt base-system cryptsetup grub-x86_64-efi neovim
```

# copy resolv.conf so dns works in the chroot

```shell
cp /etc/resolv.conf /mnt/etc/resolv.conf
```

# chroot

```shell
chroot /mnt /bin/bash
```

# set root password

```shell
passwd
```

# root permissions

```shell
chown root:root /
chmod 755 /
```

# set hostname

```shell
echo <yr-hostname> > /etc/hostname
```

# add user
```shell
useradd -m -G wheel rj1
passwd rj1
```

# enable sudo

```shell
nvim /etc/sudoers
```

# set timezone/keymap

```shell
nvim /etc/rc.conf
```

# set locale

```shell
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

uncomment your locale in `/etc/default/libc-locales`

```shell
nvim /etc/default/libc-locales
```

# enable nonfree repo + install microcode patch

```shell
xbps-install -S void-repo-nonfree
xbps-install -S intel-ucode
```

# setup fstab

```shell
nvim /etc/fstab
```

example fstab:

```
tmpfs                                           /tmp    tmpfs   defaults,nosuid,nodev   0       0
UUID=21b8b8e9-29ca-4d2f-a7fc-3face2fc2b0a       /       ext4    defaults                0       0
UUID=0536-48CF                                  /boot   vfat    defaults                0       2
```

use `:r!blkid /dev/sda2 -sUUID -ovalue` in vim to insert the desired UUID

# edit grub config

edit `/etc/default/grub`

```shell
nvim /etc/default/grub
```

append `rd.auto=1` to GRUB_CMDLINE_LINUX_DEFAULT

e.g. `GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 rd.auto=1"`

# install grub

```shell
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="void"
grub-mkconfig -o /boot/grub/grub.cfg
```

# add cryptsetup to our initramfs

```shell
echo 'add_dracutmodules+=" crypt "' > /etc/dracut.conf.d/dracutmodules.conf
```

# add hostonly setting to dracut

```shell
echo 'hostonly=yes' > /etc/dracut.conf.d/hostonly.conf
```

# build initramfs

note: the following command will reconfigure all of the packages you have
installed, this is a simple way to generate the initramfs and enable our locale
choice(s) by reconfiguring the `glibc-locales` package

```shell
xbps-reconfigure -fa
```

you can `exit` the chroot and `reboot` now

have fun!

