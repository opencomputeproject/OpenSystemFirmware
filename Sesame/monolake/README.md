This directory provides the build script to build a coreboot monolake
image and associated utilities to flash the platform.

The build requires using a Ubuntu 20.04 Linux distribution to build
the Mono Lake. You must also have the appropriate binary blobs in
the appropriate directory for the build to work.

Build instructions:

Pre-requisites:
1. mkdir cb_bin directory
2. clone the coreboot repo and build the ifdtool:
git clone https://github.com/coreboot
cd util/ifdtool
make

3. ifdtool itrenew_monolake.rom - ml.layout

4. copy the following files into the directory:
   cb_bin/monolake_fd.bin
   cb_bin/monolake_me.bin
   cb_bin/monolake_gbe.bin

These files can generated using the ifdtool located in the
coreboot git repo with a provided binary image from ITRenew.

5. mkdir  cb_bin/fsp
cb_bin/fsp/BROADWELLDE_FSP.bin


The Broadwell-DE FSP can be obtained from SysPro Consulting by request.

To setup the build environment, install the following packages on an Ubuntu 20.04 system:

apt-get install -y build-essential ncurses-dev xz-utils libssl-dev bc libelf-dev bison flex ca-certificates git zlib1g-dev libpci-dev m4 gnat libncurses5-dev curl

apt-get install -y snapd
sudo snap install go --classic

./osf_build_monolake.sh

The resultant coreboot image will be in the same directory as:
monolake_OSF_year_month_date.rom 

How to flash:

To flash, use the flashrom utility built in build/flashrom/flashrom or you can use the fw-util utility on the bmc:

On the bmc:
There are 4 slots on the Mono Lake, you need to flash each of the slots:
fw-util slotx --force --update bios monolake_OSF_year_month_date.rom

