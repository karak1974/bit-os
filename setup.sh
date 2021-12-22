#!/bin/bash

KERNEL_VERSION=5.15.6
BUSYBOX_VERSION=1.34.1
KERNEL_MAJOR=$(echo $KERNEL_VERSION | sed 's/\([0-9]*\)[^0-9].*/\1/')
BITOS_VERSION=0.1

#Downloading sources
mkdir -p src
cd src
	#Kernel
	echo "[BITOS $BITOS_VERSION] Building Kernel $KERNEL_VERSION"
	echo "[LINUX $KERNEL_VERSION] Downloading"

	if [ -f "linux-$KERNEL_VERSION.tar.xz" ]; then
		echo "[LINUX $KERNEL_VERSION] Destination file already exist"
	else
		wget https://mirrors.edge.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR.x/linux-$KERNEL_VERSION.tar.xz
		tar -xf linux-$KERNEL_VERSION.tar.xz
	fi

	echo "[LINUX $KERNEL_VERSION] Compiling"
	cd linux-$KERNEL_VERSION
		make defconfig
		make -j8 || exit
	cd ..
	echo "[LINUX $KERNEL_VERSION] Compile done"	

	#BusyBox
	echo "[BITOS $BITOS_VERSION] Building BusyBox $BUSYBOX_VERSION"
	echo "[BUSYBOX $BUSYBOX_VERSION] Downloading"

	if [ -f "busybox-$BUSYBOX_VERSION.tar.bz2" ]; then
		echo "[BUSYBOX $BUSYBOX_VERSION] Destination file already exist"
	else
		wget https://www.busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
		tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
	fi

	echo "[BUSYBOX $BUSYBOX_VERSION] Compiling"
	cd busybox-$BUSYBOX_VERSION
		make defconfig
		sed 's/^.*CONFIG_STATIC[^_].*$/CONFIG_STATIC=y/g' -i .config
		make CC=musl-gcc -j8 busybox || exit
	cd ..
	echo "[BUSYBOX $BUSYBOX_VERSION] Compile done"

cd ..

# Creating filesystem
echo "[BITOS $BITOS_VERSION] Creating Filesystem"
cp src/linux-$KERNEL_VERSION/arch/x86_64/boot/bzImage .
mkdir initrd
cd initrd

	mkdir -p bin dev proc sys
	cd bin
		cp ../../src/busybox-$BUSYBOX_VERSION/busybox ./
		
		for prog in $(./busybox --list); do
			ln -s /bin/busybox ./$prog
		done
	cd ..
	
	#Creating base files
	echo '#!/bin/sh' > init
	echo 'mount -t systs sysfs /sys' >> init
	echo 'mount -t proc proc /proc' >> init
	echo 'mount -t devtmpfs udev /dev' >> init
	echo 'sysctl -w kernel.printk="2 4 1 7"' >> init

	#Adding custom files
	echo `echo '#!/bin/sh' > bin/shutdown` >> init
	echo `echo 'poweroff -f' >> bin/shutdown` >> init

	echo '/bin/sh' >> init
	echo 'poweroff -f' >> init

	chmod -R 777 .
	find . | cpio -o -H newc > ../BitOS$BITOS_VERSION.img

cd ..



echo "[BITOS $BITOS_VERSION] Exiting"

