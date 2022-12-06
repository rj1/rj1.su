---
title: arch linux installation notes
date: "2021-05-16"
lastmod: "2022-12-05"
---

install information:
- systemd-boot
- luks encryption
- zen kernel
- sway

## verify we booted via efi

{{< highlight shell >}}
ls /sys/firmware/efi/efivars
{{< / highlight >}}

if this command shows the directory without error, proceed

## system clock

```shell
timedatectl set-ntp true
```

## partitioning

I use cfdisk

| partition | size | code | fs |
-------------------|-----------|------|------|
| boot (/dev/sda1) | 512.0 MiB | ef00 | efi  |
| root (/dev/sda2) | the rest  | 8300 | ext4 |

## create encrypted root partition

```shell
cryptsetup luksFormat /dev/sda2
cryptsetup open /dev/sda2 cryptroot
mkfs.ext4 /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt
```

## create boot partition

```shell
mkfs.fat -F32 /dev/sda1
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```

## install base arch system

```shell
pacstrap /mnt base linux-zen linux-zen-headers linux-firmware sudo neovim
```
## generate fstab file

```shell
genfstab -U /mnt /mnt/etc/fstab
```

## chroot into your fresh install

```shell
arch-chroot /mnt
```

## set timezone

```shell
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc
```

## locale

```shell
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
localectl set-locale LANG=en_US.UTF-8
```

## basic network configuration

```shell
echo "myhostname" > /etc/hostname
```

modify `/etc/hosts`

```
127.0.0.1	localhost
127.0.1.1	myhostname.localdomain	myhostname
```

replace `myhostname` with whatever you like

create `/etc/systemd/network/20-wired.network`

```
[Match]
Name=enp3s0

[Network]
DHCP=yes
DNS=1.1.1.1
DNS=1.0.0.1

[DHCP]
UseDNS=false
```

edit `/etc/systemd/resolved.conf` to change dns client settings

make sure software that relies on resolv.conf works

```shell
ln -rsf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

```shell
systemctl enable systemd-networkd systemd-resolved
```

## mkinitcpio configuration

modify `/etc/mkinitcpio.conf`, add 'encrypt' to hooks

```
HOOKS=(base udev autodetect modconf block filesystems keyboard encrypt fsck)
```

## generate initramfs

```shell
mkinitcpio -P
```

## set root passwd

```shell
passwd
```

## patch cpu microcode

install either `amd-ucode` or `intel-ucode` depending on your system's cpu

```shell
pacman -S intel-ucode
```

## software

```shell
pacman -S sudo base-devel zsh git tmux openssh
```

## create user

```shell
useradd -m -G wheel,seat -s /bin/zsh rj1
passwd rj1
```

## sudo

```shell
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
su rj1
```

## bootloader

### install systemd-boot

```shell
bootctl install
```

### create `/boot/loader/entries/arch.conf`

```shell
title   arch
linux   /vmlinuz-linux-zen
initrd  /intel-ucode.img
initrd  /initramfs-linux-zen.img
options cryptdevice=UUID=UID-GOES-HERE:cryptroot root=/dev/mapper/cryptroot rw
```

`:r!blkid /dev/sda2 -sUUID -ovalue` in vim to insert the desired UUID

### modify `/boot/loader/loader.conf`

```shell
default      arch.conf
timeout      2
console-mode max
modifyor     no
```

### review boot config

```shell
bootctl list
```

## reboot

```
exit
reboot
```

## software
```
sway waybar alacritty noto-fonts-cjk noto-fonts-emoji swappy weechat libnotify
mako notmuch mitmproxy oath-toolkit qrencode zbar grim slurp wf-recorder fzf
swaybg wl-clipboard swayidle firefox chromium ncmpcpp php python ruby ruby-docs
foot nmap bc mpd mpc ncmpcpp ripgrep fd qt5-wayland qt6-wayland mpv resolvconf
wireplumber pipewire pipewire-jack pipewire-alsa pipewire-pulse alsa-utils bat
man-db netcat rsync hugo isync msmtp w3m alot newsboat jq zathura
zathura-pdf-mupdf pass wireguard-tools yadm
```

## enable services
systemctl enable seatd

other ones like pipewire, etc.

## aur software
```shell
git clone https://aur.archlinux.org/paru-bin.git
cd paru
makepkg -si
paru -S tessen rofi-lbonn-wayland pinentry-rofi pass-coffin pass-otp vimiv-qt \
nerd-fonts-hack swaylock-effects-git nnn-nerd nvm dict dstask wob tomb rofimpd
```

```shell
yadm clone https://git.sr.ht/~rj1/dotfiles
```

have fun!

