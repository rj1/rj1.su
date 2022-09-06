---
title: fall guys on linux w/ epic overlay (no heroic)
date: "2022-08-12"
---

# install legendary

install [legendary](https://github.com/derrod/legendary) w/ your favorite
package manager (can be installed w/ python's pip as well)

```shell
sudo xbps-install legendary
```

# authenticate to legendary with your epic account

```shell
legendary auth
```

# change legendary game dir

I prefer the contents of my home directory to contain lowercase filenames, so I
changed the path where legendary installs games from the epic store. there's no
need to do this, but if you're following these notes do keep in mind that the
default location is `~/Games` rather than `~/games`

edit `~/.config/legendary/config.ini`

mine looks like:
```
[Legendary]
disable_update_check=false
disable_update_notice=true
install_dir=/home/rj1/games
```

# install fall guys

```shell
legendary install 0a2d9f6403244d12969e11da6713137b
```

# install the epic overlay

```shell
legendary eos-overlay install --prefix ~/games/FallGuys/pfx/
```

# copy eac

```shell
cp ~/games/FallGuys/EasyAntiCheat/easyanticheat_x64.so \
    ~/games/FallGuys/FallGuys_client_game_Data/Plugins/x86_64/
```

# modify FallGuys_client.ini

change `~/games/FallGuys/FallGuys_client.ini` so it references the
`FallGuys_client_game.exe`

mine looks like:
```
TargetApplicationPath=FallGuys_client_game.exe
WorkingDirectory=
WaitForExit=0
SkipEOS=0
```

# install GE-Proton

```shell
wget https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton7-29/GE-Proton7-29.tar.gz
mkdir -p ~/.steam/root/compatibilitytools.d/
tar -xf ~/dl/GE-Proton7-26.tar.gz -C ~/.steam/root/compatibilitytools.d/
```

# FallGuys.sh

```shell
#!/bin/sh
PROTON_EAC_RUNTIME="$HOME/.steam/root/steamapps/common/Proton EasyAntiCheat Runtime/" \
STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/root/" \
STEAM_COMPAT_DATA_PATH="$HOME/games/FallGuys/" \
WINEESYNC=1 \
WINEFSYNC=1 \
legendary launch 0a2d9f6403244d12969e11da6713137b \
    --no-wine \
    --wrapper "'$HOME/.steam/root/compatibilitytools.d/GE-Proton7-29/proton' run"
```

chmod +x FallGuys.sh

# steam

launch steam and install *Proton* (latest) and *Proton EasyAntiCheat* runtime.
they'll be listed under the 'tools' section of the list (I believe it's set to
only list games by default)

now you can *add a non-steam game* and select the FallGuys.sh script we made.
you should now be able to launch the game via that script from within steam.

some internet posts say you need to have your steam account linked to your epic
account in order for this to work. I can't verify that because in my case the
accounts were already linked. I would have liked to try it w/o the accounts
being linked to see if that's true or not.

have fun!

