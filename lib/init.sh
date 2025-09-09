#!/bin/sh
#
# https://shellcheck.net/wiki/SC2154
# https://shellcheck.net/wiki/SC2034
# shellcheck disable=2154,2034

set -e
unset IFS

err() {
    printf '!> %s\n' "${1:-unexpected error occurred}" >&2
}

panic() {
    err "$@"
    sh
}

panic_exec() {
    err "$@"
    exec sh
}

resolve_device() {
    device="$1"

    case "$device" in
        UUID=*|LABEL=*|PARTUUID=*|PARTLABEL=*)
            dev="$(findfs "$device")" || panic_exec "device $device not found"
            if [ -n "$dev" ]; then
                device="$dev"
            fi
            ;;
    esac
}

init_base() {
    mount -o nosuid,nodev,noexec -t proc     proc /proc
    mount -o nosuid,nodev,noexec -t sysfs    sys  /sys
    mount -o nosuid,mode=0755    -t devtmpfs dev  /dev

    ln -s /proc/self/fd   /dev/fd
    ln -s /proc/self/fd/0 /dev/stdin
    ln -s /proc/self/fd/1 /dev/stdout
    ln -s /proc/self/fd/2 /dev/stderr
}

parse_cmdline() {
    # https://kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
    # ... parameters with '=' go into init's environment ...
    for param in $(cat /proc/cmdline); do case "$param" in
        rdpanic) trap - EXIT;;
        rddebug) set -x;;

        # Maintain compatibility with kernel parameters.
        ro|rw)        export rorw="$param";;
        root=*)       export root="${param#*=}";;
        rootfstype=*) export rootfstype="${param#*=}";;
        rootflags=*)  export rootflags="${param#*=}";;
        init=*)       export init="${param#*=}";;
        --)           break;;
        *=*)          ;;
        *)            export -- "$param=";;
    esac; done
}

read_config() {
    while IFS== read -r key value; do
        key="$key="
        if ! env | cut -c1-"${#key}" | grep -Fq -- "$key"; then
            export -- "$key$value"
        fi
    done </etc/tinyramfs.conf
}

eval_hooks() {
    type="$1"

    # https://shellcheck.net/wiki/SC2086
    # shellcheck disable=2086
    { IFS=,; set -- $hooks; unset IFS; }

    for hook; do
        [ -f "/lib/hook/$hook/$type" ] || continue

        [ "$rdbreak" = "$hook" ] && panic "break before: $hook.$type"

        # https://shellcheck.net/wiki/SC1090
        # shellcheck disable=1090
        . "/lib/hook/$hook/$type"
    done
}

check_root() {
    [ "$rdbreak" = fsck ] && panic 'break before: check_root()'

    "fsck${rootfstype:+.$rootfstype}" -- "$root"
}

mount_root() {
    [ "$rdbreak" = root ] && panic 'break before: mount_root()'

    # https://shellcheck.net/wiki/SC2086
    # shellcheck disable=2086
    mount \
        -o "${rorw:-ro}${rootflags:+,$rootflags}" ${rootfstype:+-t "$rootfstype"} \
        -- "$root" /mnt || panic "failed to mount rootfs: $root"
}

boot_system() {
    [ "$rdbreak" = boot ] && panic 'break before: boot_system()'

    : "${init:=/sbin/init}"

    [ "$(stat -c %D /)" = "$(stat -c %D /mnt)" ] && panic_exec 'failed to mount the real root device'
    [ -x "/mnt$init" ] || panic_exec "root device mounted successfully, but $init does not exist"

    for dir in dev sys proc; do
        mount -o move "/$dir" "/mnt/$dir" || umount "/$dir" || :
    done

    # POSIX 'exec' has no '-c' flag to execute command with empty environment.
    # Use 'env -i' instead to prevent leaking exported variables.
    #
    # Some implementations of 'switch_root' don't conform to POSIX utility
    # guidelines and don't support '--'. This means that safety of argv
    # isn't guaranteed.
    #
    # https://shellcheck.net/wiki/SC2086
    # shellcheck disable=2086
    exec env -i TERM="$TERM" switch_root /mnt "$init" "$@"
}

# Run emergency shell if init unexpectedly exiting due to error.
trap panic_exec EXIT

init_base
parse_cmdline
read_config
eval_hooks init
resolve_device "$root"
root="$device"
check_root
mount_root
eval_hooks init.late
boot_system "$@"
