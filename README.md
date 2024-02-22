# Tinyramfs

Tiny initramfs written in POSIX shell. This project is based on https://github.com/illiliti/tinyramfs

## Features

- No no bashisms, only POSIX shell
- Portable, not distro specific
- Easy to use configuration
- Make time and init time hooks
- ZFS + native encryption support
- LUKS (detached header, key), LVM
- mdev, mdevd, eudev, systemd-udevd
- Resume from swap partition

## Dependencies

- POSIX shell
- POSIX utilities
- make
- switch_root
- mount
- cpio
- ldd
  - Required for copying binary dependencies
- ldconfig
  - Required for LUKS support
- strip
- findfs
- mdev, mdevd, eudev or systemd-udevd (optional)
  - Required for modular kernel, /dev/mapper/* and /dev/disk/* creation
- zfs (optional)
- lvm2 (optional)
- cryptsetup (optional)
- busybox loadkmap (optional)
- kmod or busybox modutils with [patch](https://gist.github.com/illiliti/ef9ee781b5c6bf36d9493d99b4a1ffb6) (already included in KISS Linux)
  - Optional. Required if kernel compiled with loadable external modules

## Installation

```sh
make PREFIX=/usr install
```

## Documentation

[Here](doc/)

## Thanks

[illiliti](https://github.com/illiliti)  
[E5ten](https://github.com/E5ten)  
[dylanaraps](https://github.com/dylanaraps)
