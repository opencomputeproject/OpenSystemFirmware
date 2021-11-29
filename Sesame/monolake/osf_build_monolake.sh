#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace
trap "exit" INT

# Build Mono Lake coreboot + Linuxboot (Linux + u-root) ROM image.
# Set the version environment variable on the command line
#   VER=nnn    -  set the firmware version string
#   ex:
#       $ VER=123  ./osf_build_monolake.sh
#
# This script requires the Intel binaries to be located in ./cb_bin.
#  See check_files() for more details.
#
# To clean for a new build:
#   rm-rf ./build/ $GOPATH/src/github.com/u-root/u-root monolake_nnn.rom
#
# See additional build instructions and details in the README.md
#

# Version defaults to OCP_YYYY-MM-DD
VER=${VER:-"OSF_$(date +%F)"}
BOARD="monolake"
ROMFILE="${BOARD}_${VER}.rom"

# Source versions
LINUX_VERSION="v5.10.44"
VPD_VERSION="release-R85-13310.B"
PCIUTILS_VERSION="v3.7.0"
COREBOOT_VERSION="440149804123c4c99041f100f0ae103103de71d1" # monolake commit on 4.11_branch
FLASHROM_VERSION="95d822e342d48bea27fb3a606b1670994c3ce5d0" # Lewisburg support
UROOT_VERSION="a6800bcddf42be434fb56dedbb996064fb3df4ff" # ITR/SysPro github

# Directories
TOPDIR="${PWD}"
WORKDIR="${TOPDIR}/build"
VPD_DIR="${WORKDIR}/vpd"
PCIUTILS_DIR="${WORKDIR}/pciutils"
FLASHROM_DIR="${WORKDIR}/flashrom"
LINUX_DIR="${WORKDIR}/linux"
CB_DIR="${WORKDIR}/cb411"
CB_BIN_DIR="${TOPDIR}/cb_bin"

# Build Artifacts
UROOTBIN="initramfs.linux_amd64.cpio"
BZIMAGE="linux-uroot.bzImage"

BUILDTHREADS="$(nproc --ignore=1)"


# Check the required files are in place
check_files() {
  local requiredfiles="cb_monolake.defconfig
linux.defconfig
cb_bin/monolake_fd.bin
cb_bin/monolake_gbe.bin
cb_bin/monolake_me.bin
cb_bin/fsp/BROADWELLDE_FSP.bin
"

  local errorreqfiles="
Error: The following files are required to build.
${requiredfiles}
The FSP is available from: TBD
The ME/SPS files are available from: TBD
"
  echo "Check Files..."
  for file in ${requiredfiles}; do
    if [[ -f "${TOPDIR}/${file}" ]]; then
      echo "Found: ${file}"
    else
      echo "Not Found: ${WORKDIR}/${file}"
      echo "${errorreqfiles}"
      exit 1
    fi
  done
  wait
}


# Get and build the vpd util
build_vpd() {
  echo "Building VPD..."
  git clone --depth 1 -b "${VPD_VERSION}" https://chromium.googlesource.com/chromiumos/platform/vpd "${VPD_DIR}"

  # Build vpd tool
  pushd "${VPD_DIR}"
  make -j"${BUILDTHREADS}"

  # Use the static linked vpd
  mv vpd_s vpd
  strip vpd
  du -hs vpd
  popd
  wait
}


# Get and build pciutils
build_pciutils() {
  echo "Building PCIutils..."
  git clone https://github.com/pciutils/pciutils.git "${PCIUTILS_DIR}"
  pushd "${PCIUTILS_DIR}"
  git checkout "${PCIUTILS_VERSION}"

  # Build pciutils staticly without udev support for flashrom
  make -j"${BUILDTHREADS}" HWDB=no SHARED=no
  popd
  wait
}


# Get and build flashrom
build_flashrom() {
  echo "Building flashrom..."
  git clone https://review.coreboot.org/flashrom.git "${FLASHROM_DIR}"
  pushd "${FLASHROM_DIR}"
  git checkout "${FLASHROM_VERSION}"

  CONFIG_STATIC=yes \
    CONFIG_ENABLE_LIBPCI_PROGRAMMERS=yes \
    CONFIG_ENABLE_LIBUSB0_PROGRAMMERS=no \
    CONFIG_ENABLE_LIBUSB1_PROGRAMMERS=no \
    CONFIG_INTERNAL=yes \
    LIBS_BASE="${PCIUTILS_DIR}" \
    make -j"${BUILDTHREADS}"
  strip flashrom
  du -hs flashrom
  popd
  wait
}


# Get and build u-root
build_uroot() {
  echo "Building u-root..."
  UROOTGIT="github.com/u-root/u-root"
  UROOT_DIR="$GOPATH"/src/"${UROOTGIT}"
  ITR_UROOTGIT="https://github.com/marcjones-syspro/u-root.git"

  GO111MODULE=off go get -v -u "${UROOTGIT}"

  # Add checkout of ITRenew version of u-root
  # This isn't required once the u-root changes are accepted upstream
  pushd "${UROOT_DIR}"
  git remote add itrenew "${ITR_UROOTGIT}"
  git fetch itrenew
  git checkout -b itrenew "${UROOT_VERSION}"
  popd

  # Build the u-root initramfs in busybox mode with the required utils etc.
  # Build all of cmds/core/ and selected cmd/boot/ and cmd/exp/.
  # When uroot loads, use systemboot to boot
  GO111MODULE=off u-root -build=bb -uinitcmd=systemboot \
   -files="${FLASHROM_DIR}/flashrom:bin/flashrom" \
   -files="${VPD_DIR}/vpd:bin/vpd" \
   core github.com/u-root/u-root/cmds/boot/{systemboot,pxeboot,boot} \
   github.com/u-root/u-root/cmds/exp/{cbmem,dmidecode,modprobe,ipmidump} \

  cp /tmp/${UROOTBIN} "${WORKDIR}"
  wait
}


# Get and build the Linux Kernel.
build_linux() {
  echo "Building Linux..."
  LINUXGIT="git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git"
  LINUXCONFIG="linux.defconfig"

  git clone --depth 1 -b "${LINUX_VERSION}" "${LINUXGIT}" "${LINUX_DIR}"

  # Build Linux kernel bzimage with u-root initramfs
  cp "${WORKDIR}/${UROOTBIN}" "${LINUX_DIR}/"
  cp "${TOPDIR}/${LINUXCONFIG}" "${LINUX_DIR}/.config"
  pushd "${LINUX_DIR}"
  make olddefconfig
  make --quiet -j"${BUILDTHREADS}" CFLAGS="-w -Os"

  cp "${LINUX_DIR}/arch/x86_64/boot/bzImage" "${CB_BIN_DIR}/${BZIMAGE}"
  popd
  wait
}


# Get and build coreboot
build_coreboot() {
  echo "Building coreboot..."

  # Use the 4.11 branch for Mono Lake
  CB_BRANCH="4.11_branch"
  CB_GIT="https://review.coreboot.org/coreboot.git"
  CB_PATCHES="${TOPDIR}/cb_patches"
  CB_CONFIG="cb_monolake.defconfig"

  git clone --depth 50 -b ${CB_BRANCH} ${CB_GIT} "${CB_DIR}"

  pushd "${CB_DIR}"
  git checkout "${COREBOOT_VERSION}"
  git am "${CB_PATCHES}"/*.patch

  # Build the coreboot toolchain
  make crossgcc-i386 CPUS="${BUILDTHREADS}"

  # Copy monolake binaries (FSP, descriptor, etc) to coreboot site-local/
  mkdir -p "${CB_DIR}/site-local/${BOARD}/"
  cp -r "${CB_BIN_DIR}"/* "${CB_DIR}/site-local/${BOARD}/"

  # Build coreboot with the Linux u-root bzimage
  cp "${TOPDIR}/${CB_CONFIG}" "${CB_DIR}/.config"
  make olddefconfig
  make -j"${BUILDTHREADS}"

  cp build/coreboot.rom "${TOPDIR}/${ROMFILE}"
  popd
  wait
}


# Set VPDs Regions and values in image
set_vpd() {
  #  Note that the vpd utility uses string values
  echo "Set VPD..."

  # Add VPD Regions
  #  Clear the VPD Partions (FMAP Regions)
  "${VPD_DIR}/vpd" -O -i RO_VPD -f "${ROMFILE}"
  "${VPD_DIR}/vpd" -O -i RW_VPD -f "${ROMFILE}"

  # Set the firmware version in RO_VPD
  "${VPD_DIR}/vpd" -f "${ROMFILE}" -i RO_VPD -s "firmware_version"="${VER}"

  # systemboot order, Allow IPMI override
  "${VPD_DIR}/vpd" -f "${ROMFILE}" -i RW_VPD -l -s "bmc_bootorder_override"="1"
  "${VPD_DIR}/vpd" -f "${ROMFILE}" -i RW_VPD -l -s "Boot0000"="{\"type\":\"boot\"}"
  "${VPD_DIR}/vpd" -f "${ROMFILE}" -i RW_VPD -l -s "Boot0001"="{\"type\":\"pxeboot\"}"
}

main() {
  echo "Building ${ROMFILE}..."

  check_files
  build_vpd
  build_pciutils
  build_flashrom
  build_uroot
  build_linux
  build_coreboot
  set_vpd

  echo "Build Finished! Get your rom file here: ${TOPDIR}/${ROMFILE}"
}

main "$@"
