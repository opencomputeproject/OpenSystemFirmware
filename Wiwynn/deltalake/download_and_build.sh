#!/bin/bash

scriptdir="$(realpath "$(dirname "$0")")"
osf_builder_hash="4f7836a3a8d1181fdc3444bfc1ea72b56de3e625"
fsp_hash="0e18518131e7ecfeeb4afeab306121ca554c5054"
edk2_non_osi_hash="eba85cf5d882340b2ce0f845facc31dde0c3dbcb"

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
  git clone https://github.com/intel/FSP.git
  cd FSP
  git checkout $fsp_hash
  mkdir CPX-FSP-split
  python Tools/SplitFspBin.py split -f CedarIslandFspBinPkg/Fsp.fd -o CPX-FSP-split
  cd $scriptdir
}

# Download Intel FSP and microcode binaries under bin
download_intel_blobs
# Download osf-builder under src
cd src
git clone https://github.com/facebookincubator/osf-builder.git
cd osf-builder
git checkout $osf_builder_hash
# Apply patches that add Delta Lake files to osf-builder
apply_patches
cp ${scriptdir}/bin/FSP/CPX-FSP-split/Fsp_M.fd projects/deltalake/blobs/Server_M.fd
cp ${scriptdir}/bin/FSP/CPX-FSP-split/Fsp_S.fd projects/deltalake/blobs/Server_S.fd
cp ${scriptdir}/bin/FSP/CPX-FSP-split/Fsp_T.fd projects/deltalake/blobs/Server_T.fd
cp ${scriptdir}/bin/edk2-non-osi/Silicon/Intel/WhitleySiliconBinPkg/CpxMicrocode/mBF5065B_07002302.mcb projects/deltalake/blobs/microcode.mcb
cp ${scriptdir}/bin/edk2-non-osi/Platform/Intel/WhitleyOpenBoardBinPkg/Ifwi/DeltaLake/FlashDescriptor.bin projects/deltalake/blobs/flashregion_0_flashdescriptor.bin
cp ${scriptdir}/bin/edk2-non-osi/Platform/Intel/WhitleyOpenBoardBinPkg/Ifwi/DeltaLake/Me.bin projects/deltalake/blobs/flashregion_2_intel_me.bin
# Run osf-builder to fetch the rest of the codes and start building
cd projects/deltalake
make
