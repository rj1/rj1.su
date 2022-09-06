---
title: sniffing android app traffic w/ genymotion + mitmproxy + frida
date: "2021-05-17"
description: getting setup to sniff android app traffic w/ genymotion + mitmproxy
---

## requirements

- virtualbox
- genymotion
- mitmproxy
- frida
- android tools

```shell
pacman -S virtualbox mitmproxy android-tools
```
```shell
yay -S genymotion
```
```shell
pip install Frida frida-tools
```
## launch genymotion and create an android vm

select 'bridge' network mode when creating the vm in genymotion

## launch mitmproxy on the host machine

## enable the proxy on android
```shell
adb shell settings put global http_proxy <ip>:<port>
```
the default port for mitmproxy is 8080

if you want to disable the proxy, use the following:
```shell
adb shell settings put global http_proxy :0
```

## install your mitmproxy ssl certificate on android

on the android vm, browse to `mitm.it`, download the certificate for android, and install it via android settings (this is a bit different in each version of android) 

note: you can do this via adb, but I find it to be more tedious

now you should be able to inspect all of the https traffic from your android device in mitmproxy, but some apps use certificate pinning. there are a few ways around this, I like using [frida](https://frida.re/)

magisk is a solution as well but it requires a more specific android environment, and is more tedious to use

## check the cpu arch of your android vm (likely x86)
```shell
adb shell getprop ro.product.cpu.abi
```
## download/install/run frida server on the android vm

head to https://github.com/frida/frida/releases and find frida-server for your vm's architecture

```shell
wget https://github.com/frida/frida/releases/download/14.2.18/frida-server-14.2.18-android-x86.xz
xz -d frida-server-14.2.18.xz
adb push frida-server-14.2.18 /data/local/tmp/frida-server
adb shell chmod 755 /data/local/tmp/frida-server
adb shell /data/local/tmp/frida-server &
```
## list running processes on your vm
```shell
frida-ps -U -a
```
## inject code into a specific process
```shell
frida -U -f com.process.name -l ssl.js -–no-pause
```
you can find various examples for this over @ https://codeshare.frida.re

e.g. https://codeshare.frida.re/@sowdust/universal-android-ssl-pinning-bypass-2/

have fun!
