# jetson-rootfs

thanks to https://github.com/vuquangtrong/jetson-custom-image.git


## prereq

- debootstrap (yay -S debootstrap)


## build


build rootfs in ./runtime/rootfs
```
task build
task optimize
```

## create os image on sdk

run on sdk
```
task sync
```

run on host
```
task sync
```

run on sdk
```
task customize
task os:build
task os:flash
```

run on orin to create partition at the end of disk with id=20
```
sgdisk --new 20::0 /dev/nvme0n1
```







