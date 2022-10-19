tinyramfs(8) "tinyramfs" "2022-05-09"

# NAME

tinyramfs - create an initramfs

# SYNOPSIS

*tinyramfs* [*-nMdh*] [*-k* kern] [*-m* path] [*-H* hooks] [*-c* util] <output>

# DESCRIPTION

The tinyramfs utility generates an initramfs image for loading kernel modules,
unlocking encrypted drives, mounting needed filesystems, etc.

# OPTIONS

*-k* <kern>
	Set the kernel version to <kern>. This way tinyramfs knows which kernel
	modules to use.

*-m* <path>
	Look for kernel modules in <path>, instead of /lib/modules/.

*-H* <hooks>
	A comma-separated list of hooks to include in the initramfs. Hooks can
	be found in /usr/lib/tinyramfs/hook/.

*-c* <util>
	Set the utility to use for compressing the initramfs. The option accepts
	arbitrary commands (eg. 'gzip -9'). Use 'cat' for an uncompressed
	initramfs.

*-n*
	Instructs tinyramfs not to include kernel modules in the initramfs.

*-M*
	Instructs tinyramfs to only copy modules specific to your system.

*-d*
	Enable debug mode; print every command tinyramfs executes to standard
	error.

*-h*
	Show a summary of options accepted by tinyramfs.

# OPTIONS

; A tinyramfs configuration file is written in POSIX sh. Configuration is done
; via variable asignment (eg. *option=value*). Special characters and whitespace
; must be quoted or escaped, more info: *sh*(1). By default tinyramfs looks to
; */etc/tinyramfs.conf* for a configuration file.

Options to tinyramfs are exposed via the environment. In fact, any of the
command line options can be set equivalently using the respective environment
variable.

Some options only apply to certain hooks and have been categorized accordingly.
Furthermore, any boot options can be overridden using the appropriate kernel
command line parameter.

Option marked with *(bool)* can hold a value of true or false. False if the
variable is unset or empty, true otherwise.

Options which expect a device as a value can also refer to the device via
*UUID*, *LABEL*, and *PARTUUID* (eg. LABEL=<label>). This requires a blkid
utility which supports that identifier.

root
	The device your root filesystem is located on.

rootfstype
	The filesystem you're using for your root device (eg. ext4).

rootflags
	Flags passed to mount when mounting the root filesystem.

ro|rw
	*(bool)* Whether to mount the root filesystem as read-only or read-write
	respectively. Only setting one is considered valid.

init
	The path to init. By default this is /sbin/init.

kernel
	Set the kernel version. This way tinyramfs knows which kernel
	modules to use.

moddir
	Look for kernel modules in <path>, instead of /lib/modules/.

hooks
	A comma separated list of hooks to include in the initramfs. Hooks can
	be found in /usr/lib/tinyramfs/hook/.

compress
	The utility to use for compressing the initramfs. The option accepts
	arbitrary commands (eg. 'gzip -9'). Use 'cat' for an uncompressed
	initramfs.

monolith
	*(bool)* Instructs tinyramfs whether or not to include kernel modules in
	the initramfs.

hostonly
	*(bool)* Whether or not to only copy modules specific to your system.

debug
	*(bool)* Whether or not to enable debug mode; print every command
	tinyramfs executes to standard error.

## KEYMAP

keymap_path
	Path to your keymap.

# MODULES

modules_load
	A comma-separated list of kernel modules to load.

## LUKS

luks_key
	Path to your LUKS keyfile.

luks_header
	Path to your LUKS header.

luks_root
	The device your LUKS volume is located on.

luks_name
	The name to map your LUKS device to.

luks_discard
	*(bool)* Allow the use of discard (TRIM) requests for your luks device.

	*WARNING*: This option may have a negative security impact. For more info
	read *cryptsetup*(8).

## LVM

lvm_config
	Path to your LVM configuration file.

lvm_group
	The name of your LVM volume group.

lvm_name
	The name of your LVM logical volume.

lvm_tag
	The tag of your LVM logical volume.

lvm_discard
	*(bool)* Allow the use of discard (TRIM) requests for your LVM device.

## ZFS

zfs_key
	Path to your ZFS keyfile.

zfs_root
	The device your ZFS volume is located on.

# FILES

/usr/lib/tinyramfs/hook/
	tinyramfs hooks

# AUTHORS

tinyramfs by illiliti *https://github.com/illiliti*++
	and neeshy *https://github.com/neeshy*++
man page by fluorescent_haze *https://github.com/fluorescent-haze*
