# Copyright (c) 2019, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.
#
# /etc/fstab: static file system information.
#
# These are the filesystems that are always mounted on boot, you can
# override any of these by copying the appropriate line from this file into
# /etc/fstab and tweaking it as you see fit.  See fstab(5).
#
# <file system> <mount point>             <type>          <options>                               <dump> <pass>
/dev/root            /                     ext4           rw,defaults,noatime                                     0 0
LABEL=STORAGE	/storage ext4 defaults,noatime,auto,nofail	0 1

#tmpfs    /var/tmp    tmpfs    defaults,noatime,nosuid,size=300m    0 0
tmpfs    /tmp    tmpfs    defaults,noatime,nosuid,size=5000m    0 0
#tmpfs    /var/log    tmpfs    defaults,noatime,nosuid,size=100m    0 0
#tmpfs    /var/lib/openntpd/    tmpfs    defaults,noatime,size=1m    0 0

#overlay /home/ubuntu overlay lowerdir=/home/ubuntu-ro,upperdir=/tmp/upper/,workdir=/tmp/workdir 0 0

#overlay /var overlay lowerdir=/var,upperdir=/tmp/upper/var,workdir=/tmp/workdir/var 0 0

#/ubuntu /ubuntu-ro none    defaults,bind 0 0
