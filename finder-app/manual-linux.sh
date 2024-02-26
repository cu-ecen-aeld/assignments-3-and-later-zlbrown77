#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

echo "Creating directory ${OUTDIR}"
mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    
    #deep clean the kernel build tree
    echo "Deep cleaning..."
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper
    
    #configure for our virt arm dev board
    echo "Configure for virtual arm dev board"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig
    
    #build a kernel image for booting with QEMU
    echo "Building kernel image"
    make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all
    
    #Build any kernel modules...is this the one that needs to be skipped?
    #make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules 
    
    #build the device tree
    echo "Building device tree"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs

fi

echo "Adding the Image in outdir"
cp "${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image" "${OUTDIR}"
echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
	
	#create folder tree
	echo "Making rootfs directory"
	mkdir rootfs
	cd rootfs
	echo "Making necessary base directories"
	mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
	echo "Making necessary usr directories"
	mkdir -p usr/bin usr/lib usr/sbin
	echo "Making var/log"
	mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
	echo "Configuring busybox"
	
	make defconfig
	echo "Busybox configured"
else
    cd busybox
    echo "Busybox already configured"
fi

# TODO: Make and install busybox
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
echo "Making busybox"
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
echo "Installing busybox"
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Library dependencies"
echo $(${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "program interpreter")
echo $(${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "Shared library")

# TODO: Add library dependencies to rootfs

# program interpreter placed in the /lib directory
cp -v $(${CROSS_COMPILE}gcc -print-sysroot)/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib/

# libraries placed in /lib64 directory
cp -v $(${CROSS_COMPILE}gcc -print-sysroot)/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64/
cp -v $(${CROSS_COMPILE}gcc -print-sysroot)/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64/
cp -v $(${CROSS_COMPILE}gcc -print-sysroot)/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64/

# TODO: Make device nodes

#null device is a known major 1 minor 3
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3

#console device is a known major 5 minor 1
sudo mknod -m 622 ${OUTDIR}/rootfs/dev/console c 5 1

# TODO: Clean and build the writer utility
cd ${FINDER_APP_DIR}
make clean
make all

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp writer ${OUTDIR}/rootfs/home/
cp finder.sh ${OUTDIR}/rootfs/home/
cp finder-test.sh ${OUTDIR}/rootfs/home/
cp autorun-qemu.sh ${OUTDIR}/rootfs/home/
cp conf/ -r ${OUTDIR}/rootfs/home

# TODO: Chown the root directory
echo "Go to rootfs directory"
cd "${OUTDIR}/rootfs/"
echo "Chown the root directory"
sudo chown -R root:root *
# TODO: Create initramfs.cpio.gz
# use the cpio utility to create a .cpio file
echo "Go to rootfs directory for .cpio creation"
cd "${OUTDIR}/rootfs"
echo "Find file"
find . |cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
echo "Go up to parent directory"
cd ..
# use gzip to compress into an .gz file
echo "Make gzip file"
gzip -f initramfs.cpio

