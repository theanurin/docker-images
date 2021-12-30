[![Docker Image Version](https://img.shields.io/docker/v/theanurin/luksoid?sort=date&label=Version)](https://hub.docker.com/r/theanurin/luksoid/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/luksoid?label=Image%20Size)](https://hub.docker.com/r/theanurin/luksoid/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/luksoid?label=Pulls)](https://hub.docker.com/r/theanurin/luksoid)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/luksoid?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/luksoid)

# Luksoid

*Luksoid* - is a Docker-based command line tool to help users to use LUKS-encrypted partition image without Linux host.

Right now, the tool is able:
* Create a LUKS-encrypted partition images
* Mount a LUKS-encrypted partition image inside container

## Image reason

* quick review LUKS-encrypted partition backups
* holds sensetive data as LUKS-encrypted partition

## Spec

### Environment variables

No any variables

### Expose ports

No any ports
 
### Volumes

* `/data` - where the tool look for  LUKS-encrypted partition images


## Inside

* [Alpine Linux](https://www.alpinelinux.org/)
* [Cryptsetup and LUKS - open-source disk encryption](https://gitlab.com/cryptsetup/cryptsetup)
* [Ext file systems utilities](https://en.wikipedia.org/wiki/E2fsprogs)
* [Nano Text Editor](https://www.nano-editor.org/)

## Launch

Before use, make an alias

```shell
IMAGES_PATH=/path/to/img

alias luksoid='docker run --privileged=true --rm --interactive --tty --mount "type=bind,source=$IMAGES_PATH,target=/data" theanurin/luksoid'
```

### Mount image

```shell
luksoid mount my-sensetive-luks.img
```
```
Checking for free loop device... Done.

Attaching the file '/data/my-sensetive-luks.img' to /dev/loop0... Done.

LUKS Opening. Now, you will be ask for a passphrase.
Enter passphrase for /data/my-sensetive-luks.img: 
LUKS Opening done.

Mounting a file system '' on LUKS-encrypted partition...
File system was mounted into '/mnt'.

Welcome!

Find your LUKS-encrypted partition in /mnt directory.

Feel free to read/write files in /mnt

[!] Do not forget exit gracefully by 'exit' command to prevent corruption of your image file 'my-sensetive-luks.img'.

bash-5.1# echo "My BTC wallet private key: xxxxxxxxxxxxxxxx" >> my-btc-wallet-keys.txt
bash-5.1# exit
exit

Umointing '/mnt'... Done.
LUKS Closing... Done.
Releasing /dev/loop0... Done.
```

### Init An Image

```shell
luksoid init --sizemb=256 --fstype=vfat my-sensetive-luks.img
```
```
Initializing a zero-based file '/data/my-sensetive-luks.img' for 256 MBytes... Done.

Checking for free loop device... Done.

Attaching the file '/data/my-sensetive-luks.img' to /dev/loop1... Done.

LUKS Formatting. Now, you will be ask for a passphrase. ALL DATA IN THE FILE '/data/my-sensetive-luks.img' WILL BE DISCARDED!!!
Enter passphrase for /data/my-sensetive-luks.img: 
LUKS Formatting done.

LUKS Opening. Now, you will be ask for the passphrase again. We have to open your LUKS image to double-check the passphrase and make filesystem 'vfat' on it.
Enter passphrase for /data/my-sensetive-luks.img: 
LUKS Opening done.

Writing zeros to the LUKS-encrypted partition. This ensures that outside world will see this as random data i.e. it protect against disclosure of usage patterns... Done.

Creating a file system 'vfat' on LUKS-encrypted partition...
Device '/dev/mapper/uncrypted-loop1':
heads:255, sectors/track:63, bytes/sector:512
media descriptor:f8
total sectors:491520, clusters:483952, sectors/cluster:1
FATs:2, sectors/FAT:3781
volumeID:61cdcedb, label:''
File system was created.

LUKS Closing... Done.
Releasing /dev/loop1... Done.
```