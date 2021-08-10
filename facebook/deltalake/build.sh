#!/bin/sh

GOLANG_URL="https://golang.org/dl/go1.15.14.linux-amd64.tar.gz"

echo "Fetching dependencies"

if [ ! -d "src" ]; then                                                   
    mkdir src                                                             
fi 

pushd src

if [ ! -d "initramfs" ]; then
    mkdir initramfs
fi

pushd initramfs
if [ ! -d "go" ]; then
    wget "${GOLANG_URL}"
    tar -xf go1.15.14.linux-amd64.tar.gz
fi

export GOROOT="${PWD}/go"
export GOPATH="${PWD}/gopath"

if [ ! -d "gopath" ]; then
    mkdir gopath
fi

go/bin/go get github.com/u-root/u-root

echo "Building u-root"
go/bin/go build github.com/u-root/u-root

./u-root -build=bb -o payload.cpio core boot

xz payload.cpio

popd # initramfs
popd # src

cp src/initramfs/payload.cpio.xz bin/deltalake/.

if [ ! -d "src/coreboot" ]; then
    git clone https://review.coreboot.org/coreboot src/coreboot
fi

echo "Building coreboot"

# Copy the configuration - build the toolchain and build coreboot.
cp bin/deltalake/defconfig src/coreboot/configs/defconfig
mkdir src/coreboot/site-local

cp -R bin/deltalake src/coreboot/site-local/.

pushd src
pushd coreboot

make crossgcc-i386 CPUS=$(nproc)
make defconfig
make

popd # coreboot
popd # src
