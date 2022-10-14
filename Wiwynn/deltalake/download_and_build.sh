#!/bin/bash

scriptdir="$(realpath "$(dirname "$0")")"
osf_builder_hash="11d894bfe70e9b371c7dba9a02c6ccb24bd0c524"
edk2_non_osi_hash="61662e8596dd9a64e3372f9a3ba6622d2628607c"

patches="${scriptdir}/src/*.patch"

apply_patches()
{
  for p in $patches
  do
    if [ -f "$p" ]
    then
      patch -p1 < "$p"
    fi
  done
}

download_intel_blobs()
{
  cd bin
  git clone https://github.com/tianocore/edk2-non-osi.git
  cd edk2-non-osi
  git checkout $edk2_non_osi_hash
  cd ..
  cd $scriptdir
}

# Download Intel FSP and microcode binaries under bin
download_intel_blobs
# Download osf-builder under src
cd src
git clone https://github.com/linuxboot/osf-builder.git
cd osf-builder
git checkout $osf_builder_hash
# Apply patches that add Delta Lake files to osf-builder
apply_patches
cp ${scriptdir}/bin/edk2-non-osi/Silicon/Intel/WhitleySiliconBinPkg/CpxMicrocode/mBF5065B_07002302.mcb projects/deltalake/blobs/microcode.mcb
cp ${scriptdir}/bin/edk2-non-osi/Platform/Intel/WhitleyOpenBoardBinPkg/Ifwi/DeltaLake/FlashDescriptor.bin projects/deltalake/blobs/flashregion_0_flashdescriptor.bin
cp ${scriptdir}/bin/edk2-non-osi/Platform/Intel/WhitleyOpenBoardBinPkg/Ifwi/DeltaLake/Me.bin projects/deltalake/blobs/flashregion_2_intel_me.bin
# Run osf-builder to fetch the rest of the codes and start building
cd projects/deltalake
make
