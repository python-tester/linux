#/bin/bash
parted -l | grep -i '^disk /dev/sd.'
mkfs.btrfs -L "raid0" -d raid0 /dev/sd[b-m]
btrfs fi sh