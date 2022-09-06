---
title: sway on void linux without elogind
date: "2022-08-14"
---

these notes don't cover configuring sway, your terminal, etc. this is simple a
a barebones breakdown of getting sway running w/ seat management and dbus.

install information:
- amd gpu
- sway
- dbus
- seatd

# install seatd

```shell
sudo xbps-install seatd
sudo ln -s /etc/sv/seatd /var/service
sudo sv enable seatd
```

# add user to appropriate groups

```shell
sudo usermod -aG _seatd,audio,video rj1
```

# PAM module: pam_rundir

on other operating systems leveraging systemd, the runtime directory is usually
created/managed by systemd-logind. since void linux does not use systemd, we'll
need to find another solution. I'd prefer not to use elogind, so the best
solution I've come across is pam_rundir. we're already using PAM so why not let
it manage our runtime directory as well? makes sense to me!

install pam_rundir module

```shell
sudo xbps-install pam_rundir
```

edit the file `/etc/pam.d/system-login`, adding:

`-session optional pam_rundir.so`

now you don't need to worry about *XDG_RUNTIME_DIR* not being set!

I've recently come across
[dumb_runtime_dir](https://github.com/ifreund/dumb_runtime_dir) as well. I
*think* the only difference is that it doesn't delete the directory on logout,
while pam_rundir does.

# dbus

enable the dbus service

```shell
sudo ln -s /etc/sv/dbus /var/service
sudo sv enable dbus
```

# install software

```shell
sudo xbps-install mesa-dri sway
```
# launch script

at this point, you should logout and log back in to continue

you should now be able to simply launch sway by doing

```shell
dbus-run-session sway
```

but I like to set a fixed dbus session address. I created a launch script
called `startw` which consists of:

```shell
#!/bin/zsh
dbus-daemon --session --nofork --nopidfile --address=$DBUS_SESSION_BUS_ADDRESS &
sway
# sway -V > /tmp/sway.log 2>&1
```

DBUS_SESSION_BUS_ADDRESS is set in my shell login profile already, but you
could set it in this launch script if you wanted to.

have fun!
